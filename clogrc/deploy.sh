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

# highlight colors
cLnx="$cC";cMac="$cW";cWin="$cE";cArm="$cS";cAmd="$cH"

# deploy a tagged release or "clogrc" or " "clogdev"
VV="$vCODE"
shVV=""
BRANCH="$(clog git branch)"
[[ "$BRANCH" != "main" ]] && VV="dev" && shVV="$VV"
[[ "$BRACH" == "rc" ]] && VV="rc" && shVV="$VV"
bPATH="$bucket/tsgbin/v$VV"
fInfo "Deploying to $cF$bPATH"

fInfo "Making build script for version$cW $VV$cT in$cF tmp/openTSG$shVV"
clog Cat core/template/deploy-clog-template.sh | sed  -r "s/CLOGVERSIONKEY/$VV/" > ./tmp/openTSG$shVV




fUpload() {
  echo "$1"
  SRC="./tmp/$1"
  src="$cF./tmp/$4$1"
  DST="$2/$1"
  dst="$cF$2/$3$1"
  fInfo "Uploading from $src to $dst$cX"

  if ! aws s3 cp  --color on $SRC $DST --recursive; then
    exit 2
  fi
  


  # return an error if this breaks
}

## extract and upload the licenses
clog install go-licenses
clog get licenses
# separate folder function
fInfo "Uploading licenses"
aws s3 cp  --color on ./tmp/go-licenses-cli "$bPATH/go-licenses-cli" --recursive


fUpload "$bBase-amd-lnx"     "$bPATH" "$cLnx" "$cAmd"
fUpload "$bBase-amd-mac"     "$bPATH" "$cMac" "$cAmd"
fUpload "$bBase-amd-win.exe" "$bPATH" "$cWin" "$cAmd"

fUpload "$bBase-arm-lnx"     "$bPATH" "$cLnx" "$cArm"
fUpload "$bBase-arm-mac"     "$bPATH" "$cMac" "$cArm"
fUpload "$bBase-arm-win.exe" "$bPATH" "$cWin" "$cArm"

# this doesn't upload anything
# fUpload "openTSG$shVV" "$CLOG_BUCKET"
echo
fInfo "You can test this version with one of ..."
fInfo "    $cC curl$cF https://mrmxf.com/${cC}get$cF/${cW}openTSG$shVV$cT  |$cC bash"
fInfo "    $cC curl$cF https://mrmxf.com/${cC}get$cF/${cW}openTSG$shVV$cT  |$cC zsh"
