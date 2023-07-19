#!/bin/bash

##Change branch to main if not in dev/staging/main
BRANCH=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p') # extract current branch


#Set up so all areas have the same set up of branches
go get gitlab.com/mmTristan/tpg-core@$BRANCH
go get gitlab.com/mmTristan/tpg-widgets@$BRANCH
go get gitlab.com/mmTristan/tpg-io

go build opentpg.go
 
#export LD_LIBRARY_PATH=$PWD/lib:$LD_LIBRARY_PATH
./opentpg --c ./verde_factory/loader.json -mnt mnt/dev/
#./opentpg --c ./art_factory/loadergrid.json -log stdout -debug
#./opentpg --c ./ebu/loadergrid.json -log stdout -debug
#./opentpg --c ./ebu/loaderaces.json -log stdout -debug

./opentpg --c ./verde_factory/loader.json -log stdout -debug
#./opentpg --c ./src/test.json -log stdout -debug
#./opentpg --c ./example/arrayoverwriting.json -log stdout -debug

./opentpg --c ./example/sequence.json -log stdout -debug
<<<<<<< HEAD
htop
=======
htop
>>>>>>> 05d54b9b0bbc16f6efb5d524bf2db85f6fc906e8
