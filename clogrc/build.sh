#  clog> build
# short> build & inject metadata into clog
# extra> build & inject metadata into clog
#                             _                                       _
#   ___   _ __   ___   _ _   | |_   ___  __ _   ___   _ _    ___   __| |  ___
#  / _ \ | '_ \ / -_) | ' \  |  _| (_-< / _` | |___| | ' \  / _ \ / _` | / -_)
#  \___/ | .__/ \___| |_||_|  \__| /__/ \__, |       |_||_| \___/ \__,_| \___|
#        |_|                            |___/

[ -f clogrc/common.sh ] && source clogrc/common.sh           # helper functions
# -----------------------------------------------------------------------------

[ -f clogrc/check.sh ] && source clogrc/check.sh  ignore  # preflight - no warn
printf "${cT}Project$cS $PROJECT$cX\n"

# -----------------------------------------------------------------------------

# determine local OS & CPU
fMachine
fEcho "Build   on $cS${cOS}$cT with $cK${cPU}$cT architecture"

# export the commit ID & date & type for the build
CID=$(git rev-list -1 HEAD)
DATE=$(date +%F)
SemSfx="$( git branch --show-current )"
[[ "main" == "$SemSfx" ]] && SemSfx=""


# load in the arrays of variants & the EXE & EXElocal variables
source clogrc/build-variants.sh
APP="$EXE"

# build the artifacts
mkdir -p tmp
LEN=${#gOS[@]}
for i in {1..$LEN}; do
  OS=${gOS[$i]}
  CPU=${gARCH[$i]}
  fInfo "Build   ${cVER[$i]}${FILE[$i]}${cT} ($OS for $CPU) with metadata"
  LDF=("-X main.LDos=$OS")
  LDF+="-X main.LDcpu=$CPU"
  LDF+="-X main.LDcommit=$CID"
  LDF+="-X main.LDdate=$DATE"
  LDF+="-X main.LDsuffix=$SemSfx"
  LDF+="-X main.LDappname=$APP"
  LDFLAGS=$(printf " %s" "${LDF[@]}") # make a long linker loader string
  GOOS=$OS GOARCH=$CPU go build -ldflags "$LDFLAGS" -o tmp/${FILE[$i]}
done

fInfo "To have a local $cS${cOS}$cT build on $cK${cPU}$cT, you might want:"
fInfo "   $cC rm $cF ./$EXE $cC && ln $cF $EXElocal ./$EXE $cX"
