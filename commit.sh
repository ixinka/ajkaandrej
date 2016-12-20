#!/bin/bash

echo "Commit all changes in the local repository"

if [ -z "$1" ]
  then
      echo "Missing commit message as argument ./commit.sh <MESSAGE>"
      exit 0;
fi

git status -s

read -p "Do you want to commit all changes? [y/n] " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1
fi

git add -A && git commit -m "$1"

echo "Finished"
