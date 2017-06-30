# nextcloud-scripts

This repository contains some useful scripts to work on Nextcloud.

## copyLabels

This is a admin tool to copy labels from the server repository over to another repositories. `feature:` labels will be ignored. Already existing labels will be updated.

### Configuration

You need a github.conf file in the root folder which looks like this:

```
[auth]
token = <your github auth token>
```

### Usage
`python copyLabels.py -r <repository>`

##### Arguments:

`-r`, `--repository=<repository>`: repository which should be updated

##### Optional Arguments:

`--init`: this means you want to initialize an new repository, already existing labels will be deleted

## initNextcloud

a script to set up a new Nextcloud installation or reset a existing one for development purpose. It creates 10 users and also download the most important apps

### Usage

`./initNextcloud.sh`

## switchBranch

Allows you to switch Nextcloud and all installed app to a new branch or tag. The script needs to be executed in the root of the Nextcloud installation. If no branch/tag is given the script will switch the installation to master

### Usage

`./switchBranch.sh <branch/tag>`
