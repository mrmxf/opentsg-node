# DOCKER STEPS

## Before running the docker file
These steps are requried to avoid compile errors.

Run go mod vendor, this installs all the packages locally and stops us passing the gitlab token to the docker image.
```go mod vendor```

Move a copy of inc and lib to open-tpg/vendor/gitlab.com/mmTristan/msg-sth-writer, the compiler searches for the shared libraries here instead of the root.


## Making the docker image
Run the following command ro build the docker image, the run1 is the tag of the image and can be changed to be anything you like.
```docker build -t open-tpg:run1 -f Dockerfile .```

## Running the docker image
The image is set up to run ./open-tpg --c ./verde_factory/loader.json as default. Where the entry point is run ./open-tpg --c 

The docker can be assigned a name with the --name command. E.g.

```docker run --name myfirsttpg open-tpg:run1```

### with 1 command
When running with 1 command the target json can be changed
```docker run open-tpg:run1 new.json```

### with multiple commands
With muliple commands an extension to ./open-tpg --c is added so the following comamnd:

```docker run open-tpg:run1 bin/bash/ -c ./verde_factory/loader.json -mnt fake/```
runs inside the container
``` ./open-tpg --c ./verde_factory/loader.json -mnt fake/```