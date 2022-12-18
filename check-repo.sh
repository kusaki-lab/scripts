#!/usr/bin/env bash

REPO_BACE=$HOME/src
while read dir; do
  echo ==========
  cd $dir
  pwd
  git fetch
  git status
done <<EOF
$REPO_BACE/dotfiles
$REPO_BACE/scripts
EOF
  
