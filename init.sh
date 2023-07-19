#!/bin/bash

if [ -z "$GITLAB_PAT" ] ; then echo "env GITLAB_PAT is unset - aborting" ; exit 1 ; fi
if [ -z "$GITHUB_PAT" ] ; then echo "env GITHUB_PAT is unset - aborting" ; exit 1 ; fi

if [ -z "$GIT_USER" ] ; then
  GIT_USER=mmTristan
  echo "env GIT_USER is unset using default $GIT_USER"
fi

#Set GOPRIVATE to handle both types of git with the comma seperating them
go env -w GOPRIVATE=gitlab.com/*,github.com/*

#Add the two passwords for the git machines
read -r -d '' gitAccess << EOM
machine gitlab.com login $GIT_USER password $GITLAB_PAT

machine github.com login $GIT_USER password $GITHUB_PAT
EOM

#Generate the netrc
echo "$gitAccess">$HOME/.netrc
echo "CONFG: $gitAccess"

BRANCH=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p') # extract current branch
echo "BRANCH: $BRANCH"

go get gitlab.com/mmTristan/tpg-core@$BRANCH
go get gitlab.com/mmTristan/tpg-widgets@$BRANCH
go get gitlab.com/mmTristan/tpg-io@$BRANCH


# link the libraries for testing purposes
#ln -s inc ./framehandlers/save/inc
# ln -s lib ./framehandlers/save/lib
