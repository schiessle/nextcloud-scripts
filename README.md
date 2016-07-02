# nextcloud-scripts

This repository contains some useful scripts to work on Nextcloud.

## copyLabels

This is a admin tool to copy labels from the server repository over to another repositories. `feature:` labels will be ignored. Existig Labels get updated to the values given my the server repository.

### Configuration

You need a github.conf file in the root folder which looks like this:

```
[auth]
token = <your github auth token>
```

### Usage
`python copyLabels.py -r <repository>`

### More Arguments

````
-r, --repository=<repository>: repository which should be updated
````

Optional Arguments:

````
--init: this means you want to initialize an new repository, existing labels will be deleted

````

## initNextcloud

a script to set up a new Nextcloud installation or reset a existing one for development purpose. It creates 10 users and also download the most important apps

### Usage

`./initNextcloud.sh`
