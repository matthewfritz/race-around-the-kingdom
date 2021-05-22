# Configuration File Overview

Contents of optional deployment configuration file `deploy-ghp-config.conf` should be formatted like the following example:

```
DEPLOY_DIR="docs"
DEFAULT_COMMIT_MSG="Deployed necessary items to the $DEPLOY_DIR directory"
DEPLOY_FILES_PATH="deploy-ghp-files.txt"
```

Each line may only contain a single configuration entry.

Configuration entries that you do not wish to override the default values should be removed or commented-out with the # character.

## Valid Configuration Entries

The following are the valid configuration entries:
* `DEPLOY_DIR` - the deployed files/directories will be written to this directory
* `DEFAULT_COMMIT_MSG` - default commit message when pushing upstream without a custom message
* `DEPLOY_FILES_PATH` - path to the [optional deploy file](https://gist.github.com/matthewfritz/97f08e955c8077d50dfd178aa20c937a#gistcomment-3752526) containing the deployment file list

The contents of this file will override the matching variable names at runtime.