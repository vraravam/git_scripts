#!/bin/bash

# This script can be used to clone all remote branches of a git repo
# @see http://stevelorek.com/how-to-shrink-a-git-repository.html

for branch in `git branch -a | grep remotes | grep -v HEAD | grep -v master`; do
  git branch --track ${branch##*/} $branch
done
