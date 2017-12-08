#!/bin/bash
# switch to a new branch or tag, if no parameter given we switch to master
# script needs to be executed in the root of a Nextcloud installation

#launch ssh agent
eval `ssh-agent -s`
ssh-add

if [ $# -eq 0 ]
  then
    branch=master
else
    branch=$1
fi

for f in apps/*; do
    if [[ -d $f ]]; then
	echo "switch $f to $branch"
        cd $f
	git checkout $branch &> /dev/null
	# keep this out for now, for performance reasons
	#exit_status=$?
	#if [ $exit_status -eq 1 ]; then
	#    git fetch &> /dev/null
    	#    git checkout $branch &> /dev/null
	#fi
	cd - &> /dev/null
    fi
done

echo "run git fetch..."
git fetch &> /dev/null
echo "switch server to $branch"
git checkout $branch &> /dev/null
echo "run git pull..."
git pull &> /dev/null
echo "update submodules..."
git submodule update --init

ssh-add -D
