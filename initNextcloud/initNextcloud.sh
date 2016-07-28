#!/bin/bash

database='sqlite'
number_of_users=10
root='/home/schiesbn/repos/nextcloud/server/'
inst_dir='master'
admin_user='admin'
admin_password='admin'

declare -A apps=(
    ['files_texteditor']='git@github.com:owncloud/files_texteditor.git'
)

# install or reset server
if [ -d $root$inst_dir ]; then
    echo "Reset server installation"
    cd $root$inst_dir
    git checkout master
    git pull
    # cleanup data directory
    sudo rm $root$inst_dir/data/* -rf
    #cleanup config.php
    sudo rm $root$inst_dir/config/config.php
else
    echo "Install new server"
    mkdir $root$inst_dir
    cd $root$inst_dir
    git clone git@github.com:nextcloud/server.git .
fi

git remote add owncloud git@github.com:owncloud/core.git
git fetch owncloud

echo "Update 3rd party repository"
cd $root/$inst_dir
git submodule update --init

# set the correct permissions for the data folder
echo "Update data folder permissions"
sudo chmod 770 $root$inst_dir/data
sudo chown www-data:www-data $root$inst_dir/data

# set the correct permissions for the apps folder
echo "Update apps folder permissions"
sudo chmod 770 $root$inst_dir/apps
sudo chown www-data:www-data $root$inst_dir/apps

# install apps
for key in "${!apps[@]}"; do
    if [ -d $root$inst_dir/apps/$key ]; then
	echo "Reset $key"
	cd $root$inst_dir/apps/$key
	git checkout master
	git pull
    else
	echo "Install $key"
	mkdir $root$inst_dir/apps/$key
	cd $root$inst_dir/apps/$key
	echo "git clone ${apps[$key]} ."
	git clone ${apps[$key]} .
    fi
done

# execute initial setup
echo "Run initial setup"
sudo -u www-data $root$inst_dir/occ maintenance:install --database=$database --admin-user=$admin_user --admin-pass=$admin_password

# set the correct permissions for the config.php
echo "Update config permissions"
sudo chmod 770 $root$inst_dir/config
sudo chmod 660 $root$inst_dir/config/config.php

# create users
echo "Create $number_of_users users"
for (( i=1; i<=$number_of_users; i++ ))
do
    curl http://$admin_user:$admin_password@localhost/$inst_dir/ocs/v1.php/cloud/users -d userid="user$i" -d password="user$i" &> /dev/null
done
