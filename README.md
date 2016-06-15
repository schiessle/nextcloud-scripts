# nextcloud-scripts

This repository contains some useful scripts to work on Nextcloud.

## copyLabels.py

This is a admin tool to copy labels from the server repository over to another repositories. `feature:` labels will be ignored.

### Configuration

You need a github.conf file in the root folder which looks like this:

```
[auth]
token = <your github auth token>
```

### Usage
`python copyLabels.py <repository>`
