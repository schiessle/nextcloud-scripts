#!/bin/bash
# switch to a new branch or tag, if no parameter given we switch to master
# script needs to be executed in the root of a Nextcloud installation

branch="master"
fast_forward=true

for i in "$@"
do
    case $i in
	-u|--update)
            fast_forward=false
	    ;;
	-h|--help)
	    echo ""
	    echo "Usage: switchBranch [OPTION] [branch]"
	    echo ""
	    echo "Branch is optional, if nothing is specified we will switch to master"
	    echo ""
	    echo "-u, --update       will perform 'git fetch' and git pull' to make sure that all repositories are up-to-data (will take longer)"
	    echo ""
	    exit;
	    ;;
	*)
            branch=$i
	    ;;
    esac
done

#launch ssh agent
eval `ssh-agent -s`
ssh-add

for f in apps/*; do
    if [[ -d $f/.git ]]; then
	echo "switch $f to $branch"
        cd $f
	git checkout $branch &> /dev/null
	if [ "$fast_forward" = false ]; then
	    exit_status=$?
	    if [ $exit_status -eq 1 ]; then
		git fetch &> /dev/null
		git checkout $branch &> /dev/null
	    fi
	    git pull &> /dev/null
	fi
	cd - &> /dev/null
    fi
done

if [ "$fast_forward" = false ]; then
    echo "run git fetch..."
    git fetch &> /dev/null
fi
echo "switch server to $branch"
git checkout $branch &> /dev/null
if [ "$fast_forward" = false ]; then
    echo "run git pull..."
    git pull &> /dev/null
fi
echo "update submodules..."
git submodule update --init

ssh-add -D
