#!/bin/sh
echo -e "\033[0;32mDeploying updates to GitHub...\033[0m"

hugo

# Add changes to git.
git add -A

# Commit changes.
msg="rebuilding site `date`"
if [ $# -eq 1 ]
  then msg="$1"
fi
git commit -m "$msg"

git push origin hugo
git subtree push --prefix public origin master

# Use the following if you get into fast forward nonsense
# git push origin `git subtree split --prefix public master`:master --force
