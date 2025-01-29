#  clog> deploy
# short> push executables to s3
# extra> Edit script to configure upload.
#
#     |          |
# ,---|,---.,---.|    ,---.,   .
# |   ||---'|   ||    |   ||   |
# `---'`---'|---'`---'`---'`---|
#           |              `---'
# bitbucket instructions https://support.atlassian.com/bitbucket-cloud/docs/deploy-build-artifacts-to-bitbucket-downloads/
# ------------------------------------------------------------------------------
# load build config and script helpers
[ -f clogrc/_cfg.sh   ] && source clogrc/_cfg.sh
if [ -z "$(echo $SHELL|grep zsh)" ];then source <(clog Inc); else eval"clog Inc";fi

fInfo "Building Project$cS $bPROJECT$cT (use clog deploy continue to ignore errors)"

clog Check
clog Check deploy
[ $? -gt 0 ] && [ -z "$1" ] && echo "clog Check failed aborting ..." && exit 1
# ------------------------------------------------------------------------------

CACHE="s3://mmh-cache"
BOT=$MM_BOT
BRANCH="staging"
REPO=$(basename $GITPOD_REPO_ROOT)

# deploy a tagged release or "clogrc" or " "clogdev"
VV="$vCODE"
shVV=""
BRANCH="$(clog git branch)"
[[ "$BRANCH" != "main" ]] && VV="dev" && shVV="$VV"
[[ "$BRACH" == "rc" ]] && VV="rc" && shVV="$VV"
bPATH="$bucket/tsgbin/v$VV"
fInfo "Deploying to $cF$bPATH"

OPT="--include \"*\" "
ACTION=Upload

# do preflight checks & abort if user does not want to continue
source $GITPOD_REPO_ROOT/clogrc/core/s3sync.sh
fValidate
# ------------------------------------------------------------------------------

#define the folders to sync(upload) - one per line
# SYNCS=(
#   "$OPT site/folder1   $CACHE/$BOT/$BRANCH/$REPO/folder1"
#   "$OPT site/folder2   $CACHE/$BOT/$BRANCH/$REPO/folder2"
# )

# do sync
# fSync

EXE=msgtsg
# do anything remedial like single file copies here....
fnInfo "Project(${cH}$(basename $GITPOD_REPO_ROOT)${cT}) create$cF _lx$EXE-so.zip"
zip -j _lx$EXE-so.zip lib/*

fnInfo "Project(${cH}$(basename $GITPOD_REPO_ROOT)${cT}) sync$cF _lx$EXE-so.zip"
aws s3 cp ./_lx$EXE-so.zip s3://mmh-cache/bot-bdh/staging/get/_lx$EXE-so.zip

fnInfo "Project(${cH}$(basename $GITPOD_REPO_ROOT)${cT})$cF removing .zip"
rm _lx$EXE-so.zip

fnInfo "Project(${cH}$(basename $GITPOD_REPO_ROOT)${cT}) sync$cF tpg binaries"
aws s3 cp ./_la$EXE s3://mmh-cache/bot-bdh/staging/get/_la$EXE
aws s3 cp ./_lx$EXE s3://mmh-cache/bot-bdh/staging/get/_lx$EXE
aws s3 cp ./_win$EXE.exe s3://mmh-cache/bot-bdh/staging/get/_win$EXE.exe

aws s3 cp ./clogrc/tpg-installer.sh s3://mmh-cache/bot-bdh/staging/get/$EXE
