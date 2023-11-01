
#!/bin/bash -eo pipefail
vless="${VERSION:1}"
rcless="${vless%%-*}"
formula_version="${rcless%.*}"
branch="update_aperture_${VERSION}"
msg="Update brews for release ${VERSION}"

git checkout -B "${branch}"
./scripts/update_brews.py add-version "${formula_version}"
./scripts/update_brews.py delete
./scripts/update_brews.py update

git status
git diff

git add .
git commit -m "${msg}"

# Because we use shallow clone above, the new branch won't be tracked
# and gh cli will stop to ask what to do.
# Instead we can change git configuration to tell it to track all remote branches
git remote set-branches origin '*'
# Push and create PR
git push --set-upstream origin "${branch}"
gh pr create --title "${msg}" --body "" --label "pr-pull"
