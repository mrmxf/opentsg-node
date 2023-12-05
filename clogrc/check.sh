 # clog> check
# short> pre-build & deploy checks
# extra> $1 == "ignore" to ignore warnings
#                             _                               _      _
#   ___   _ __   ___   _ _   | |_   ___  __ _   ___   _ __   | |_   | |
#  / _ \ | '_ \ / -_) | ' \  |  _| (_-< / _` | |___| | '  \  | ' \  | |
#  \___/ | .__/ \___| |_||_|  \__| /__/ \__, |       |_|_|_| |_||_| |_|
#        |_|                            |___/
[ -f clogrc/common.sh ] && source clogrc/common.sh  # helper functions

# --- status ------------------------------------------------------------------
OOPS=0                                          # non zero problem count is bad

# --- functions ---------------------------------------------------------------

# getRemoteTag "opentsg-component" "ref" # get tag. [ -z "$2" ] adds color
function getRemoteTag () {
  local URL="https://github.com/mrmxf/$1.git"
  local TAG=$(git ls-remote --tags $URL v\* 2>/dev/null | head -1 | sed -r 's/.*(v[\.0-9]*).*/\1/')
  [ $? -ne 0 ]  && ((OOPS++)) && return $OOPS         # unknown error on stdout
  if [ -z "$2" ] ; then
    # make all the non-matching tags red
    [[ "$TAG" == "" ]]       && TAG="no tag"
    [[ "$TAG" != "$vREF" ]] && TAG="$cE$TAG"  &&   ((OOPS++))
  fi
  printf $TAG
  return $OOPS
}

# Print out the status of something
# $1 = category string e.g. "github"
# $2 = msg text
# $3 = highlight for the thing (e.g. $cE for error)
# $4 = name of the thing
# $5 = flag for the reference tag
function fReport() {
  isRef=""
  [[ -n "$5" ]] && isRef="$cE<$cW--$cI--$cS--ref tag$cX"
  case "$1" in
    "golang" | "python" | "code")  category=$(printf "${cC}%10s" "$1") ;;
    "local")                       category=$(printf "${cI}%10s" "$1") ;;
    "github")                      category=$(printf "${cS}%10s" "$1") ;;
    "gitlab")                      category=$(printf "${cW}%10s" "$1") ;;
    "*")                           category=$(printf "${cT}%10s" "$1") ;;
  esac
  msg=$(printf "$cT %11s" "$2")
  printf "${category} $msg $3$4 $isRef$cX\n"
}

# --- git repo dependencies ---------------------------------------------------
dC=() ; dVer=() ;  ; dName=()   ; dRepo=()
n="opentsg-node"   ; dName+="$n"; dRepo+="https://github.com/mrmxf/$n.git"
n="opentsg-modules"; dName+="$n"; dRepo+="https://github.com/mrmxf/$n.git"
n="opentsg-mhl"    ; dName+="$n"; dRepo+="https://github.com/mrmxf/$n.git"

# --- git working tree handling -----------------------------------------------
issue=$(git status | grep 'not stage')
[ -n "$issue" ] && printf "${cE}Stage$cT or$cW Stash$cT changes before build$cX\n" && ((OOPS++))

issue=$(git status | grep 'hanges to be comm')
[ -n "$issue" ]  && printf "${cE}Commit$cT changes before build$cX\n" && ((OOPS++))

issue=$(git status | grep 'branch is ahead')
[ -n "$issue" ]  && printf "${cE}Push$cT changes before build$cX\n" && ((OOPS++))

issue=$(git status | grep 'working tree clean')
[ -z "$issue" ] && printf "${cE}Changes!$cT Working tree must be$cS clean$cT before build$cX\n" && ((OOPS++))

# --- tag handling ------------------------------------------------------------
gBRANCH=$(git branch --show-current)
vCODE=$(awk 'match($0, /"([^"]*)/) { print substr($0, RSTART+1, RLENGTH-1) }' ./versionstr/releases.yml | head -1)
vLOCAL=$(git tag | tail -1)       && [ -z "$vLOCAL" ] && vLOCAL="$untagged"
vHEAD=$(git tag --points-at HEAD) && [ -z "$vHEAD" ]  && vHEAD="${cW}untagged"

vREF="$vCODE"
[[ "$vLOCAL" != "$vREF" ]] && vLOCAL="${cE}$vLOCAL"
[ $OOPS -gt 0 ] && vLOCAL="$cW$vLOCAL"  # use color to warn that tag is dirty

# print out the BRANCH we're on - show main in red, rc in green
cZ="$cT"
[[ "main" == "$gBRANCH" ]] && cZ=$cE
[[ "rc"   == "$gBRANCH" ]] && cZ=$cS
fReport "local" "branch" "$cZ" $gBRANCH

# get tag from the repos & update error count from the subprocess
for i in ${#dRepo[@]}; do
  ver=$( getRemoteTag ${dRepo[$i]} ) ; OOPS=$?
  dVer+=ver
  fReport "github" ${dName[$i]} $cT $ver
done

#print out the matching tags
fReport "golang" "code" "$cS" $vCODE isRef

fReport "local"  "git latest"  "$vLOCAL"
fReport "local"  "git HEAD"    "$vHEAD"

# --- tag fixup ---------------------------------------------------------------

if [[ "$vLOCAL" != "$vREF" ]] ; then
  fPrompt "${cT}Tag$cS $PROJECT$cT locally @ $vREF?$cX" "yN" 6
  if [ $? -eq 0 ] ; then # yes was selected
    printf "Tagging local with $vREF.\n"
    fTagLocal "$vREF" "matching tag to release ($vREF)"
    [ $? -gt 0 ] && printf "${cE}Abort$cX\n" && exit 1
    vLOCAL=$(git tag | tail -1)
  fi
fi

if [[ ( "$vHEAD" == "$vREF" ) && ( "$vRnode" != "$vREF" ) ]] ; then
  fPrompt "${cT}Push$cS $PROJECT$cT to origin @ $vREF?$cX" "yN" 6
  if [ $? -eq 0 ] ; then # yes was selected
    printf "Pushing $vREF to origin.\n"
    fTagRemote "$vREF"
    [ $? -gt 0 ] && printf "${cE}Abort$cX\n" && exit 1
  fi
fi

# --- environemnt variables ---------------------------------------------------

[ -z "$PROJECT " ] && printf "${cT}env$cE PROJECTI$cT not set.\n" && ((OOPS++))

# --- exit handling -----------------------------------------------------------
if [[ "ignore" == "$1" ]] ; then
  [ $OOPS -gt 0 ] && printf "${cT}Ignoring $cW$OOPS$cT issues from$cC check$cX.\n"
else
  if [ $OOPS -gt 0 ] ; then
    git status --branch --short
    printf "${cE}Error $cW$OOPS$cT issues from$cC check$cX.\n"
    exit $OOPS
  fi
fi
