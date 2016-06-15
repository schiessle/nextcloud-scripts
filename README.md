# nextcloud-scripts

This repository contains some useful scripts to work on Nextcloud.

## copyLabels.py

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
