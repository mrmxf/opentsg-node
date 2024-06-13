#  clog> build
# short> build & inject metadata into a go project
# extra> push main executables into tmp/
#                       _
#   _ __    ___  __ _  | |_   ___  __ _
#  | '  \  (_-< / _` | |  _| (_-< / _` |
#  |_|_|_| /__/ \__, |  \__| /__/ \__, |
#               |___/             |___/

source clogrc/core/inc.sh
PROJECT=$(basename $(pwd))
fInfo "Project$cS $PROJECT"
# ------------------------------------------------------------------------------

# determine local OS & CPU
fMachine
fEcho "Building on $cS${cOS}$cT with $cK${cPU}$cT architecture"

# export the commit ID & today's date for the build
ID=$(git rev-list -1 HEAD)
DT=$(date +%F)
APP="msgtsg"

# load in the arrays of variants & the EXE & EXElocal variables
source clogrc/go-variants.sh

mkdir -p tmp
for (( i=0; i<${#gOS[@]}; i++ ));
do
  OS=${gOS[$i]}
  CPU=${gARCH[$i]}
  fInfo "Building ${cVER[$i]}${FILE[$i]}${cT} ($OS for $CPU) with metadata"
  GOOS=$OS GOARCH=$CPU go build -ldflags "-X main.LDos=$OS -X main.LDcpu=$CPU  -X main.LDcommit=$ID -X main.LDdate=$DT -X main.LDappname=$APP"  -o tmp/${FILE[$i]}
done

fInfo "To have a local $cS${cOS}$cT build on $cK${cPU}$cT, you might want:"
fInfo "   $cC rm $cF ./$EXE $cC && ln $cF $EXElocal ./$EXE $cX"

# tag the local head ...
# -v return only the semantic version vM.m.c
TAG=$($EXElocal -v)
# --note returns the note for this tag
MSG=$($EXElocal --note)
# LOCAL will be null or there is a local tag that matches
LOCAL=$(git tag | grep $TAG)
# REMOTE returns the most recent matching tag if there is one
REMOTE=$(git ls-remote --tags origin | egrep -o "v[0-9]+\.[0-9]+\.[0-9]+" | head -1)

[ -n "$LOCAL" ]  && fWarning "LOCAL tag $TAG exits -$cW git tag -d $TAG$cT & rebuild." &&  exit 1
[ -n "$REMOTE" ] && fWarning "REMOTE $TAG exists - delete & rebuild of update releases.yml" && exit 1
[ -n "$(git status | grep 'not stage')" ] && git status && fWarning "${cE}Stage$cT your changes to allow tagging" && exit 1
[ -n "$(git status | grep 'hanges to be comm')" ] && git status && fWarning "${cE}Commit$cT your changes to allow tagging" && exit 1
[ -n "$(git status | grep 'branch is ahead')" ] && git status && fWarning "${cE}Push$cT your changes to allow tagging" && exit 1
[ -z "$(git status | grep 'working tree clean')" ] && git status && fWarning "${cE}???$cT Working Tree must be clean to allow tagging" && exit 1

fWarning "Tagging local HEAD with $TAG for use with$cC clog stage"
fInfo "          remote HEAD adds $TAG during$cC clog stage" # git push origin $TAG
git tag -a "$TAG" HEAD -m "$MSG"
fInfo "git tag ..."
git tag
