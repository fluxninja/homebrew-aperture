#!/usr/bin/env python3

from __future__ import annotations
import argparse
from collections import defaultdict
import contextlib
import dataclasses
from functools import cached_property, wraps
import hashlib
import itertools
import logging
import os
from pathlib import Path
import re
import shlex
import subprocess
import sys
import tempfile
from typing import Callable, Dict, Iterable, NamedTuple, Optional, Sequence, Set, Tuple
import urllib.request

last_quote_content_matcher = re.compile(r'^(?P<before>.*)"(?P<inside>[^"]*)"$')


@dataclasses.dataclass(frozen=True)
class Repo:
    owner: str
    name: str

    @cached_property
    def _logger(self) -> logging.Logger:
        return logging.getLogger(f"{self.owner}/{self.name}")

    @wraps(subprocess.run)
    def _run(self, cmd: Sequence[str], /, *args, **kwargs):
        cmd = tuple(cmd)
        self._logger.debug(f"Running command: {shlex.join(cmd)}")
        kwargs.setdefault("check", True)
        kwargs.setdefault("stdout", subprocess.PIPE)
        return subprocess.run(cmd, *args, **kwargs)

    @contextlib.contextmanager
    def temp_clone(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            url = self.get_clone_url()
            logging.debug(f"Cloning {url} to {tmpdir}")
            self._run(["git", "clone", url, str(tmpdir)])
            yield self.to_cloned_repo(Path(tmpdir))

    def to_cloned_repo(self, directory: Path) -> ClonedRepo:
        return ClonedRepo(**dataclasses.asdict(self), directory=directory)

    def get_clone_url(self) -> str:
        return f"https://github.com/{self.owner}/{self.name}.git"

    def get_tarball_url(self, ref: str) -> str:
        return f"https://github.com/{self.owner}/{self.name}/archive/refs/tags/{ref}.tar.gz"


@dataclasses.dataclass(frozen=True)
class ClonedRepo(Repo):
    directory: Path

    def _run(self, cmd, /, *args, **kwargs):
        kwargs.setdefault("cwd", self.directory)
        return super()._run(cmd, *args, **kwargs)

    def git(self, *args: str) -> str:
        return self._run(("git", *args), text=True).stdout.rstrip("\n")

    def get_current_branch(self) -> str:
        return self.git("rev-parse", "--abbrev-ref", "HEAD")

    def get_commit_hash(self, ref: str = "HEAD") -> str:
        return self.git("log", ref, "-n1", "--format=%H")

    def is_tag(self, tag: str) -> bool:
        try:
            self._run(["git", "show-ref", "--verify",
                      "--quiet", f"refs/tags/{tag}"])
            return True
        except subprocess.CalledProcessError as err:
            if err.returncode == 1:
                return False
            raise

    def get_version_tags(self) -> Tuple[Version, ...]:
        return tuple(map(Version.from_str, self.git("tag", "-l", "v*").split("\n")))


@dataclasses.dataclass(frozen=True)
class Version:
    major: int
    minor: int
    patch: int
    rc: Optional[int]

    def as_key(self) -> Tuple[int, int, int, int]:
        return (self.major, self.minor, self.patch, self.rc or 9001)

    def __str__(self) -> str:
        v = f"v{self.major}.{self.minor}.{self.patch}"
        if self.rc:
            v = f"{v}-rc.{self.rc}"
        return v

    @classmethod
    def from_str(cls, version) -> Version:

        if not version.startswith("v"):
            raise ValueError(f"Not a valid version: {version}")
        parts = version[1:].split(".")
        if len(parts) not in (3, 4):
            raise ValueError(f"Invalid parts to version: {version}")
        major = int(parts[0])
        minor = int(parts[1])
        patch = int(parts[2].split("-")[0])
        rc = int(parts[3]) if len(parts) == 4 else None
        return cls(major, minor, patch, rc)


def update_formula(content: str, replacements: Dict[str, str]) -> str:
    """Update formula, replacing previous values with the new ones

    >>> update_formula('ENV["GIT_BRANCH"] = "main"', dict(GIT_BRANCH="stable"))
    'ENV["GIT_BRANCH"] = "stable"'
    """
    lines = content.split("\n")
    for line_matcher, value in replacements.items():
        for lineidx, line in enumerate(lines):
            if line_matcher in line:
                match = last_quote_content_matcher.match(line)
                # assert (
                #    match
                # ), f"Unable to replace content for '{line_matcher}' in '{line}'"
                if match:
                    lines[lineidx] = f'{match.group("before")}"{value}"'
    return "\n".join(lines)


def update_formulasss(formulas: Iterable[Path], replacements: Dict[str, str]):
    for formula in formulas:
        content = formula.read_text()
        new_content = update_formula(content, replacements)
        if content != new_content:
            formula.write_text(new_content)


def get_latest_release(releases: Tuple[Version, ...]) -> Version:
    full_releases = tuple(
        release for release in releases if release.rc is None)
    assert full_releases, "Release list is empty!"
    return next(iter(get_latest_releases(full_releases)))


def get_latest_releases(releases: Tuple[Version, ...]) -> Iterable[Version]:
    """Get latest release for each major/minor version, ignoring patch/rc"""

    sorted_releases = sorted(releases, key=Version.as_key, reverse=True)

    result = []
    seen = set()
    for release in sorted_releases:
        key = (release.major, release.minor)
        if key not in seen:
            result.append(release)
            seen.add(key)

    return result


def get_remote_file_sha256(url: str) -> str:
    with urllib.request.urlopen(url) as f:
        checksum = hashlib.sha256()
        checksum.update(f.read())
        return checksum.hexdigest()


@contextlib.contextmanager
def get_aperture_repo(repo_dir: Optional[str] = None):
    aperture_repo = Repo(owner="fluxninja", name="aperture")
    if repo_dir != None:
        repo_path = Path(repo_dir)
        assert repo_path.exists(), f"Not existent APERTURE_DIR: {repo_dir}"
        yield aperture_repo.to_cloned_repo(repo_path)
    else:
        with aperture_repo.temp_clone() as cloned_repo:
            yield cloned_repo


@dataclasses.dataclass(frozen=True)
class FormulaVersion:
    major: int
    minor: int

    def __str__(self) -> str:
        return f"{self.major}.{self.minor}"

    @classmethod
    def from_version(cls, version: Version) -> FormulaVersion:
        return cls(version.major, version.minor)

    @classmethod
    def from_str(cls, version: str) -> FormulaVersion:
        split = version.split(".")
        if len(split) != 2:
            raise ValueError(f"Invalid formula version: {version}")
        return cls(*tuple(map(int, split)))


@dataclasses.dataclass(frozen=True)
class Formula:
    _path: Path

    def __post_init__(self):
        if self.filename == self.full_name:
            raise ValueError(f"Not a path to formula: {self._path}")

    @cached_property
    def filename(self) -> str:
        return self._path.name

    @cached_property
    def full_name(self) -> str:
        return self.filename.rstrip(".rb")

    @cached_property
    def name(self) -> str:
        return self.full_name.split("@")[0]

    @cached_property
    def version(self) -> Optional[FormulaVersion]:
        split = self.full_name.split("@")
        assert len(split) <= 2
        if len(split) == 2:
            return FormulaVersion.from_str(split[1])
        return None

    def copy(self, new_version: FormulaVersion, exists_ok: bool = False, recreate: bool = False) -> Formula:
        new_path = self._path.with_stem(f"{self.name}@{new_version}")
        new_formula = Formula(new_path)
        if new_path.exists():
            if not exists_ok:
                raise FileExistsError(new_path)
            if not recreate:
                return new_formula
        content = self._path.read_text()
        new_path.write_text(self._change_formula_class_version(
            content, str(new_version)))
        return new_formula

    def delete(self) -> None:
        self._path.unlink()

    def update(self, replacements: FormulaReplacements) -> bool:
        return self._modify_content(replacements.apply)

    def _modify_content(self, modifier: Callable[[str], str]) -> bool:
        content = self._path.read_text()
        new_content = modifier(content)
        changed = content != new_content
        if changed:
            self._path.write_text(new_content)
        return changed

    @staticmethod
    def _change_formula_class_version(content: str, version: str) -> str:
        lines = content.split("\n")
        assert lines
        class_line = lines[0]
        line_split = class_line.split()
        assert len(line_split) == 4
        assert line_split[0] == "class"
        assert line_split[2] == "<"
        assert line_split[3] == "Formula"
        class_name = line_split[1].split("AT")[0]
        class_version = version.replace(".", "")
        line_split[1] = f"{class_name}AT{class_version}"
        lines[0] = ' '.join(line_split)
        return "\n".join(lines)

    @staticmethod
    def _set_keg_only(content: str) -> str:
        lines = content.split("\n")
        place_for_keg = None
        for lineidx, line in enumerate(lines):
            parts = line.split()
            if not place_for_keg and "depends_on" in parts:
                place_for_keg = lineidx - 1
            if "keg_only" in parts:
                return content
        assert place_for_keg
        lines[place_for_keg:place_for_keg] = [
            "", "  keg_only :versioned_formula"]
        return "\n".join(lines)

    def set_keg_only(self) -> bool:
        return self._modify_content(self._set_keg_only)


class Replacement(NamedTuple):
    value: str
    matches: Callable[[str], bool]


@dataclasses.dataclass(frozen=True)
class FormulaReplacements:
    install_branch: str
    head_branch: str
    commit_hash: str
    archive_url: str
    archive_hash: str

    def as_replacements(self) -> Iterable[Replacement]:
        return (
            Replacement(self.install_branch,
                        lambda line: 'git_branch' in line and '"' in line),
            Replacement(self.commit_hash,
                        lambda line: 'git_commit_hash' in line and '"' in line),
            Replacement(self.head_branch,
                        lambda line: "branch:" in line.split()),
            Replacement(self.head_branch,
                        lambda line: "head_branch=" in line),
            Replacement(self.archive_url, lambda line: "url" in line),
            Replacement(self.archive_hash, lambda line: "sha256" in line),
            # Legacy replacements from build.sh era
            Replacement(self.install_branch,
                        lambda line: '"GIT_BRANCH"' in line),
            Replacement(self.commit_hash,
                        lambda line: '"GIT_COMMIT_HASH"' in line),
        )

    def apply(self, content: str) -> str:
        lines = content.split("\n")
        for idx, replacement in enumerate(self.as_replacements()):
            for lineidx, line in enumerate(lines):
                if replacement.matches(line):
                    match = last_quote_content_matcher.match(line)
                    if match:
                        lines[lineidx] = f'{match.group("before")}"{replacement.value}"'
                        # We only replace in first matching line
                        break
            else:
                logging.warning(f"No lines matched for replacement nr. {idx}: {replacement.value}")
        return "\n".join(lines)


def load_formulas_from_dir(path: Path) -> Tuple[Formula, ...]:
    if not path.is_dir():
        raise ValueError(f"Not a directory: {path}")
    return tuple(map(Formula, path.glob("*.rb")))


GroupedFormulas = Dict[str, Set[Formula]]


def group_formulas(formulas: Iterable[Formula]) -> GroupedFormulas:
    grouped_formulas = defaultdict(set)
    for formula in formulas:
        grouped_formulas[formula.name].add(formula)
    return dict(grouped_formulas)


def delete_unsupported_versions(grouped_formulas: GroupedFormulas, supported_versions: Set[FormulaVersion]) -> None:
    for component, formulas in grouped_formulas.items():
        component_versions = set(f.version for f in formulas)
        versions_to_delete = component_versions - supported_versions - {None}
        logging.debug(
            f"Removing versions for {component}: {versions_to_delete}")
        formulas_to_delete = set()
        for formula in formulas:
            if formula.version in versions_to_delete:
                formula.delete()
                formulas_to_delete.add(formula)
        formulas -= formulas_to_delete


def add_version(repo: ClonedRepo, formulas_dir: Path, version: FormulaVersion, components: Iterable[str]):
    formulas = load_formulas_from_dir(formulas_dir)
    components = set(components)
    new_formulas = []
    for formula in formulas:
        if formula.version is not None:
            continue
        if not components or formula.name in components:
            new_formula = formula.copy(version, exists_ok=True, recreate=False)
            new_formula.set_keg_only()
            new_formulas.append(new_formula)
    update_formulas(repo, new_formulas)


def get_stable_branch_name_for_version(version: Version) -> str:
    return f"stable/v{version.major}.{version.minor}.x"


def update_formulas(repo: ClonedRepo, formulas: Iterable[Formula]):
    releases = repo.get_version_tags()
    latest_versions = get_latest_releases(releases)
    formula_to_latest_version = {
        FormulaVersion(v.major, v.minor): v
        for v in latest_versions
    }
    latest_version = get_latest_release(releases)
    for formula in formulas:
        if formula.version is None:
            version = latest_version
            head_branch = "main"
        else:
            version = formula_to_latest_version[formula.version]
            head_branch = get_stable_branch_name_for_version(version)
        install_branch = get_stable_branch_name_for_version(version)
        url = repo.get_tarball_url(str(version))
        replacements = FormulaReplacements(
            install_branch=install_branch,
            head_branch=head_branch,
            commit_hash=repo.get_commit_hash(str(version)),
            archive_url=url,
            archive_hash=get_remote_file_sha256(url),
        )
        formula.update(replacements)


def main(sys_args) -> int:
    logging.basicConfig(level=logging.DEBUG)
    parser = argparse.ArgumentParser(
        description='Manage components and versions')
    parser.add_argument('--formula-dir', help='The directory containing the formulas',
                        default=Path(__file__).parent / "../Formula")
    parser.add_argument(
        "--aperture-repo", help="Path to aperture repo to use instead of cloning", default=os.environ.get("APERTURE_REPO", None))

    # Create a sub-parser for the two sub-commands
    sub_parsers = parser.add_subparsers(dest='command')
    add_parser = sub_parsers.add_parser(
        'add-version', help='Add a new version for a component')
    add_parser.add_argument('version', help='The version to add')
    add_parser.add_argument(
        'components', nargs="*", help='The component to add a version for')
    update_parser = sub_parsers.add_parser(
        'update', help='Update the components')
    update_parser.add_argument(
        'formulas', nargs='*', help='The formulas to update')
    _delete_parser = sub_parsers.add_parser(
        'delete', help='Delete unsupported components')
    args = parser.parse_args(sys_args)

    formula_dir = Path(args.formula_dir)

    with get_aperture_repo(args.aperture_repo) as repo:
        if args.command == 'add-version':
            add_version(repo, formula_dir, FormulaVersion.from_str(
                args.version), components=args.components)
        elif args.command == 'update':
            formulas = tuple(Formula(Path(f)) for f in args.formulas)
            if not formulas:
                formulas = load_formulas_from_dir(formula_dir)
                logging.info(f"Automatically loaded {len(formulas)} formulas")
            update_formulas(repo, formulas)
        elif args.command == "delete":
            formulas = load_formulas_from_dir(formula_dir)
            logging.info(f"Automatically loaded {len(formulas)} formulas")
            versions = repo.get_version_tags()
            latest_versions = get_latest_releases(versions)
            supported_versions = itertools.islice(latest_versions, 3)
            supported_formula_versions = set(
                map(FormulaVersion.from_version, supported_versions))
            delete_unsupported_versions(group_formulas(
                formulas), supported_formula_versions)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
