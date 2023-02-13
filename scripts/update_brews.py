#!/usr/bin/env python3

from __future__ import annotations
import contextlib
import dataclasses
from functools import cached_property, wraps
import hashlib
import logging
import os
from pathlib import Path
import re
import shlex
import subprocess
import sys
import tempfile
from typing import Dict, Iterable, Sequence, Tuple
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
        return f"https://github.com/{self.owner}/{self.name}/archive/{ref}.tar.gz"


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

    def get_version_tags(self) -> Tuple[str, ...]:
        return tuple(self.git("tag", "-l", "v*").split("\n"))


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


def update_formulas(formulas: Iterable[Path], replacements: Dict[str, str]):
    for formula in formulas:
        content = formula.read_text()
        new_content = update_formula(content, replacements)
        if content != new_content:
            formula.write_text(new_content)


def get_latest_release(releases: Tuple[str, ...]) -> str:
    full_releases = tuple(
        release for release in releases if "rc" not in release)
    assert full_releases, "Release list is empty!"
    return max(
        full_releases, key=lambda version: tuple(
            int(v) for v in version[1:].split("."))
    )


def get_remote_file_sha256(url: str) -> str:
    with urllib.request.urlopen(url) as f:
        checksum = hashlib.sha256()
        checksum.update(f.read())
        return checksum.hexdigest()


@contextlib.contextmanager
def get_aperture_repo():
    aperture_repo = Repo(owner="fluxninja", name="aperture")
    repo_dir = os.environ.get("APERTURE_DIR")
    if repo_dir != None:
        repo_path = Path(repo_dir)
        assert repo_path.exists(), f"Not existent APERTURE_DIR: {repo_dir}"
        yield aperture_repo.to_cloned_repo(repo_path)
    else:
        with aperture_repo.temp_clone() as cloned_repo:
            yield cloned_repo


def main(files) -> int:
    logging.basicConfig(level=logging.DEBUG)
    if not files:
        print(f"USAGE: {__file__} <formulas>")
        print("You can set following env vars:")
        print("APERTURE_DIR - path to local aperture, to skip cloning the repo")
        print("BRANCH - override the branch to set in the formula")
        print("VERSION - use this version (instead of latest)")
        print("EXAMPLE:")
        print('BRANCH=stable/v0.23.x VERSION=v0.23.0-rc.1 APERTURE_DIR=../aperture scripts/update_brews.py Formula/aperturectl.rb')
        return 1

    with get_aperture_repo() as repo:
        branch = os.environ.get("BRANCH") or repo.get_current_branch()
        version = os.environ.get("VERSION") or get_latest_release(
            repo.get_version_tags())
        assert repo.is_tag(version), f"{version} is not a tag!"
        commit_hash = repo.get_commit_hash(ref=version)
        url = repo.get_tarball_url(version)
        replacements = dict(
            GIT_BRANCH=branch,
            GIT_COMMIT_HASH=commit_hash,
            url=url,
            sha256=get_remote_file_sha256(url),
        )
        update_formulas(map(Path, files), replacements)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
