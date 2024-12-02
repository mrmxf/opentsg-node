# clog> build
# short> build & inject metadata into clog
# extra> push main executables into tmp/
#
#      |                |         o|        |
# ,---.|    ,---.,---.  |---..   ..|    ,---|
# |    |    |   ||   |  |   ||   |||    |   |
# `---'`---'`---'`---|  `---'`---'``---'`---'
#                `---'
# ------------------------------------------------------------------------------
# load build config and script helpers

[ -f clogrc/_cfg.sh   ] && source clogrc/_cfg.sh
if [ -z "$(echo $SHELL|grep zsh)" ];then source <(clog Inc); else eval"clog Inc";fi

fInfo "Building Project$cS $PROJECT"
clog Check
[ $? -gt 0 ] && exit 1
# ------------------------------------------------------------------------------

mkdir ./tmp

# determine local OS & bCPU
bCPU=amd && case $(uname -m) in arm*) bCPU="arm";; esac
case "$(uname -s)" in
   Linux*)  bOSV=Linux;;
  Darwin*)  bOSV=Mac;;
        *)  bOSV="untested:$(uname -s)";;
esac

fInfo "build OS $cS${bOSV}$cT on $cH${bCPU}$cT architecture"
# create linker data info: "commithash|auto-date|suffix|appname|apptitle"
ldi="$bHASH||$bSUFFIX|$bBASE|OpenTSG"



# highlight colors
cLnx="$cC";cMac="$cW";cWin="$cE";cArm="$cS";cAmd="$cH"
date=$(date '+%Y-%m-%d')
# --- amd ---------------------------------------------------------------------
ldi="-X main.LDos=linux -X main.LDcpu=amd64 -X main.LDcommit=$bHASH -X main.LDdate=$date -X main.LDappname=OpenTSG"

printf "${cT}Build$cLnx linux$cAmd amd64$cX size:$cLnx "
f=tmp/$bBASE-amd-lnx

# go build -ldflags -X main.LDos=linux -X main.LDcpu=amd64

GOOS="linux" GOARCH="amd64" go build -ldflags "$ldi" -o  $f
du --apparent-size --block-size=M $f; printf "$cX"

printf "${cT}Build$cMac  darwin$cAmd amd64$cX size:$cMac "
ldi="-X main.LDos=darwin -X main.LDcpu=amd64 -X main.LDcommit=$bHASH -X main.LDdate=$date -X main.LDappname=OpenTSG"
f=tmp/$bBASE-amd-mac
GOOS="darwin" GOARCH="amd64" go build -ldflags "$ldi" -o  $f
du --apparent-size --block-size=M $f; printf "$cX"

printf "${cT}Build$cE windows$cAmd amd64$cX size:$cE "
f=tmp/$bBASE-amd-win.exe
ldi="-X main.LDos=windows -X main.LDcpu=amd64 -X main.LDcommit=$bHASH -X main.LDdate=$date -X main.LDappname=OpenTSG"
GOOS="windows" GOARCH="amd64" go build -ldflags "$ldi" -o $f
du --apparent-size --block-size=M $f; printf "$cX"

# --- arm ---------------------------------------------------------------------
printf "${cT}Build$cLnx   linux$cArm arm64$cX size:$cLnx "
f=tmp/$bBASE-arm-lnx
ldi="-X main.LDos=linux -X main.LDcpu=arm64 -X main.LDcommit=$bHASH -X main.LDdate=$date -X main.LDappname=OpenTSG"
GOOS="linux" GOARCH="arm64" go build -ldflags "$ldi" -o  $f
du --apparent-size --block-size=M $f; printf "$cX"

printf "${cT}Build$cMac  darwin$cArm arm64$cX size:$cMac "
f=tmp/$bBASE-arm-mac
ldi="-X main.LDos=darwin -X main.LDcpu=arm64 -X main.LDcommit=$bHASH -X main.LDdate=$date -X main.LDappname=OpenTSG"
GOOS="darwin" GOARCH="arm64" go build -ldflags "$ldi" -o  $f
du --apparent-size --block-size=M $f; printf "$cX"

printf "${cT}Build$cE windows$cArm arm64$cX size:$cE "
f=tmp/$bBASE-arm-win.exe
ldi="-X main.LDos=windows -X main.LDcpu=arm64 -X main.LDcommit=$bHASH -X main.LDdate=$date -X main.LDappname=OpenTSG"
GOOS="windows" GOARCH="arm64" go build -ldflags "$ldi" -o  $f
du --apparent-size --block-size=M $f; printf "$cX"

# printf "${cT}Build$cS wasm$cS arm64$cX$cS"
#f=tmp/wasm-$bBASE
# GOOS="js" GOARCH="wasm" go build -ldflags "-X $ldp=$ldi" -o  $f
# du --apparent-size --block-size=1 $f; printf "$cX"

fInfo "${cT}All built to the$cF tmp/$cT folder\n"