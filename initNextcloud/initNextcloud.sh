#!/bin/bash

eval `ssh-agent -s`
ssh-add

database='sqlite'
number_of_users=10
root='/home/schiesbn/repos/nextcloud/server/'
admin_user='admin'
admin_password='admin'

while getopts b:s:d: option
do
 case "${option}"
 in
     b) branch=${OPTARG};;
     d) inst_dir=${OPTARG};;
     s) storage=${OPTARG};;
 esac
done


if [ -z $branch ]
then
    branch='master'
fi


if [ -z $inst_dir ]
then
    inst_dir='master'
fi

if [ -z $storage ]
then
    storage="fs"
fi

if [ $storage == "s3" ]
then
    killall fakes3
    rm -rf /home/schiesbn/tmp/fakes3
    fakes3 --root /home/schiesbn/tmp/fakes3 --port 4567 &
    autoconf="<?php\n
\$AUTOCONFIG = array (
'objectstore' =>\n
		array (\n
    'class' => 'OC\\Files\\ObjectStore\\S3',\n
    'arguments' => \n
    array (\n
      'bucket' => 'abc',\n
      'key' => '123',\n
      'secret' => 'abc',\n
      'hostname' => '127.0.0.1',\n
      'port' => '4567',\n
      'use_ssl' => false,\n
      'use_path_style' => true,\n
    ),\n
  ),\n
)\n
"
    sudo rm $root$inst_dir/config/autoconfig.php
    echo -e $autoconf > $root$inst_dir/config/autoconfig.php
fi


declare -A apps=(
    ['files_texteditor']='git@github.com:nextcloud/files_texteditor.git'
    ['notifications']='git@github.com:nextcloud/notifications.git'
    ['firstrunwizard']='git@github.com:nextcloud/firstrunwizard.git'
    ['activity']='git@github.com:nextcloud/activity.git'
    ['password_policy']='git@github.com:nextcloud/password_policy.git'
    ['files_videoplayer']='git@github.com:nextcloud/files_videoplayer.git'
    ['gallery']='git@github.com:nextcloud/gallery.git'
)

# install or reset server
if [ -d $root$inst_dir ]; then
    echo "Reset server installation"
    cd $root$inst_dir
    git checkout $branch
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
    git checkout $branch
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
	git pull
	git checkout $branch
    else
	echo "Install $key"
	mkdir $root$inst_dir/apps/$key
	cd $root$inst_dir/apps/$key
	echo "git clone ${apps[$key]} ."
	git clone ${apps[$key]} .
	git checkout $branch
    fi
done

if [ $storage == "s3" ]
then
    exit 0;
fi

# execute initial setup
echo "Run initial setup"
sudo -u www-data php $root$inst_dir/occ maintenance:install --database=$database --admin-user=$admin_user --admin-pass=$admin_password

# set the correct permissions for the config.php
echo "Update config permissions"
sudo chmod 770 $root$inst_dir/config
sudo chmod 660 $root$inst_dir/config/config.php

# create users
echo "Create $number_of_users users"

# disable password policy
sudo -u www-data $root$inst_dir/occ app:disable password_policy

for (( i=1; i<=$number_of_users; i++ ))
do
    curl http://$admin_user:$admin_password@localhost/$inst_dir/ocs/v1.php/cloud/users -d userid="user$i" -d password="user$i" -H "OCS-APIRequest: true" &> /dev/null
done

# enable password policy
sudo -u www-data $root$inst_dir/occ app:enable password_policy


ssh-add -D
