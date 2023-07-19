# usage> mount
# short> execute mnt.sh to mount s3 of {{REPO}}
# long>  execute mnt.sh to mount s3 of {{REPO}} to dev . Edit script to configure upload.
#   __  __    ___    _   _   _  _   _____
#  |  \/  |  / _ \  | | | | | \| | |_   _|
#  | |\/| | | (_) | | |_| | | .` |   | |
#  |_|  |_|  \___/   \___/  |_|\_|   |_|


source $GITPOD_REPO_ROOT/clogrc/core/mm-core-inc.sh
fnInfo "Project(${cH}$(basename $GITPOD_REPO_ROOT)${cT})$cF $(basename $0)"

# ------------------------------------------------------------------------------
CACHE="mmh-cache"
BOT="bot-tlh"
BRANCH=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p') # extract current branch
REPO=${PWD##*/} # extract repo name
MNT="mnt"

ACTION="mount"
# ------------------------------------------------------------------------------
# do preflight checks & abort if user does not want to continue
source $GITPOD_REPO_ROOT/clogrc/core/s3sync.sh
fValidate
# ------------------------------------------------------------------------------
# check if there's a folder in the bucket to mount and if not make a simple readme
#s3fs -f mmh-cache:/bot-tlh/dev/open-tpg mnt -o profile=bot-tlh -o dbglevel="debug"
files=$(aws s3 ls s3://$CACHE/$BOT/$BRANCH/$REPO --profile $BOT) # check if our target folder exists
if [[ $? != 0 ]]; then
echo "Generating a simple file to create a valid s3 path for s3://$CACHE/$BOT/$BRANCH/$REPO"
echo "A simple file to intialise the s3 file system" > init.md

# create a folder in the parent then disconnect
# add our generated file
s3fs $CACHE:/$BOT/$BRANCH/ $MNT -o profile=$BOT
    if [[ $? != 0 ]]; then
        #this will do the trick for the moment 
        fnAbort "${cT}Error setting up initial folder using s3fs fuse.$cX";
    fi
mkdir $MNT/$REPO
cp init.md $MNT/$REPO/init.md
fusermount -u $MNT
rm init.md #remove the file we just generated and added and disconnect the bucket
fi


s3fs $CACHE:/$BOT/$BRANCH/$REPO mnt -o profile=$BOT
if [[ $? == 0 ]]; then
echo -e "${CSgreen}Sucess${Coff} s3 mount added at for $CACHE/$BOT/$BRANCH/$REPO made at $MNT"
else
echo -e "${Cred}Error${Coff} encountered, mount not added at $MNT"
fi
#fusermount -u mnt mnt/open-tpg
