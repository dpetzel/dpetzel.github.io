

git subtree push --prefix public origin master

# Use the following if you get into fast forward nonsense
# git push origin `git subtree split --prefix public master`:master --force
