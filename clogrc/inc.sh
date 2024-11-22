## -----------------------------------------------------------------------------
## Gitpod / Website Core Include Functions
##
## Usage in a script
##   source clogrc/core/inc/sh
##
## Usage as a CLI - see installers.sh
##   source|bash  clogrc/core/inc.sh <echo|list|app> opt1 opt2
##
## check cINC_ERR - the return value from sourcing this file
## -----------------------------------------------------------------------------
cINC_VERSION=0.5
cINC_ERR=0
# simple test for some ZSH alternate paths
cIsZSH=$(echo $0 | grep "zsh")

if [ -n "$cIsZSH" ]; then
	# print "zsh tracing functions"
	# print "  funcfiletrace $funcfiletrace"
	# print "funcsourcetrace $funcsourcetrace"
	# print "      funcstack $funcstack"
	# print "      functrace $functrace"
	# remove the filename from the function stack path
	cCORE_FOLDER=${funcstack%/*}
	cINC_SCRIPT=$funcstack
else
	cCORE_FOLDER=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
	cINC_SCRIPT=${BASH_SOURCE[0]}
fi

export cINC_VERSION
export cIsZSH
export cCORE_FOLDER
export cINC_SCRIPT

# set up some colors to make the output pretty
Cblack="\e[30m"
Cred="\e[31m"
Cgreen="\e[32m"
Cyellow="\e[33m"
Cblue="\e[34m"
Cmagenta="\e[35m"
Ccyan="\e[36m"
Cwhite="\e[37m"
Cgray="\e[90m"
CSblack="\e[90m"
CSred="\e[91m"
CSgreen="\e[92m"
CSyellow="\e[93m"
CSblue="\e[94m"
CSmagenta="\e[95m"
CScyan="\e[96m"
CSwhite="\e[97m"
CSgray="\e[37m"
Bblack="\e[40m"
Bred="\e[41m"
Bgreen="\e[42m"
Byellow="\e[43m"
Bblue="\e[44m"
Bmagenta="\e[45m"
Bcyan="\e[46m"
Bwhite="\e[47m"
Bgray="\e[100m"
BSblack="\e[100m"
BSred="\e[101m"
BSgreen="\e[102m"
BSyellow="\e[103m"
BSblue="\e[104m"
BSmagenta="\e[105m"
BScyan="\e[106m"
BSwhite="\e[107m"
BSgray="\e[47m"
Coff="\e[0m"
cX=$Coff
cO=$Coff

Ccmd=$cX$Cblue
cC=$Ccmd
Curl=$cX$Ccyan
cU=$Curl
Ctxt=$cX$Cblack
cT=$Ctxt
Cinfo=$cX$Cyellow
cI=$Cinfo
Cerror=$cX$Cred
cE=$Cerror
Cwarning=$cX$CSmagenta
cW=$Cwarning
Csuccess=$cX$CSgreen
cS=$Csuccess
Cok=$Cgreen
cK=$Cok
Cfile=$cX$Cwhite
cF=$Cfile
Cheading=$cX$Cblue$BSyellow
cH=$Cheading

# ------------------------------------------------------------------------------
#define a function to echo a message - color initialised as text

fEcho() {
	# 1st parameter might by a keyword to control color ERROR / WARNING / INFO then print the rest

	if [ -n cIsZSH ]; then
		local lastline=$(echo $functrace | tail -1)
		local ln=${lastline##*:}
	else
		# printf '%s\n' "${FUNCNAME[@]}" ; printf '%s\n' "${BASH_LINENO[@]}"
		local csl
		let csl=${#FUNCNAME[@]}-2
		local ln=${BASH_LINENO[$csl]}
		if [ $ln -lt 10 ]; then ln="0$ln"; fi
		if [ $ln -lt 100 ]; then ln="0$ln"; fi
	fi

	case "$1" in
	"ABORT")
		shift
		MSG="${Cerror}  ABORT "
		;;
	"ERROR")
		shift
		MSG="${Cerror}  ERROR "
		;;
	"WARNING")
		shift
		MSG="${Cwarning}WARNING "
		;;
	"INFO")
		shift
		MSG="${Cinfo}   INFO "
		;;
	"SUCCESS")
		shift
		MSG="${CSgreen}SUCCESS "
		;;
	"TEXT")
		shift
		MSG="        "
		;;
	*)
		MSG="        "
		;;
	esac
	printf "$cC$ln$cI>>$MSG$cT$@$cX\n"
}

# ------------------------------------------------------------------------------
#define an abort function
fAbort() {
	#param $1 = message
	#find the calling function in the call stack (csl)
	#this is the (call stack length-1) minus another 1 because its zero based
	local csl
	let csl=${#FUNCNAME[@]}-2
	fEcho "ABORT" "${Cerror}Abort called from ${cX}${FUNCNAME[csl]}${Cerror} at line${cX} ${BASH_LINENO[csl]}"
	exit -1
}

# ------------------------------------------------------------------------------
# Helper functions for warnings etc
fOk() { fEcho SUCCESS "$@"; }
fInfo() { fEcho INFO "$@"; }
fText() { fEcho TEXT "$@"; }
fWarning() { fEcho WARNING "$@"; }
fError() { fEcho ERROR "$@"; }
fDivider() { fInfo "$cI==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ===="; }

# ------------------------------------------------------------------------------
# display color highlighting
fColors() {
	#echo "All variables starting with C:${!C*}"
	printf "key>>       $cC Ccmd $cU Curl $cT Ctxt $cI Cinfo $cE Cerror $cW Cwarning $CF Cfile $cT script v$cI$cINC_VERSION\n"
	if [ $1 ]; then
		fError "errors are$cE red$cX"
		fWarning "warnings are$cW pink$cX"
		fOk "success in$cK lightgreen$cX"
		fText "plain text is$cT lightyellow$cX"
		fInfo "info meesages are$cI darkgray$cX"
		fEcho "files are in$cF white $cX""
   fEcho "command lines are in$cC green $cX""
		fEcho "urls are in$cU cyan $cX"
	fi
}

# ------------------------------------------------------------------------------
fWget() {
	if [ -z $1 ]; then
		fAbort "fn_wget ERROR: missing local_name${Ctxt} usage: fWget tmp/file https://url/thing.sh"
	fi
	if [ -z $2 ]; then
		fAbort "fn_wget ERROR: missing source url${Ctxt} usage: fWget tmp/file https://url/thing.sh"
	fi
	#use curl to fetch the file. Fail if 404 error
	CURL_TEXT=$(curl --fail --silent --show-error $2 >$1)
	CURL_STATUS=$?

	if [[ $cURL_STATUS -eq 0 ]]; then
		fOk "get $Cfile $1$Ctxt from ${Ccyan}$2"
	else
		fError "get $Cfile $1$Ctxt from ${Ccyan}$2"
	fi
	#  echo ... curl returned $gotit
	#gotit=$(curl  $2 > $1)

	if [[ "$2" == *.sh ]]; then
		chmod +x $1
		fOk "make$Cfile $1$Ctxt executable"
	fi
}

# ------------------------------------------------------------------------------
# get the line number of the calling function being executed from the stack
function fGetStack() {
	STACK=""
	local i message="${1:-""}"
	local stack_size=${#FUNCNAME[@]}
	# to avoid noise we start with 1 to skip the get_stack function
	for ((i = 1; i < $stack_size; i++)); do
		local func="${FUNCNAME[$i]}"
		[ x$func = x ] && func=MAIN
		local linen="${BASH_LINENO[$((i - 1))]}"
		local src="${BASH_SOURCE[$i]}"
		[ x"$src" = x ] && src=non_file_source

		STACK+=$'\n'"   at: "$func" "$src" "$linen
	done
	STACK="${message}${STACK}"
}

# ------------------------------------------------------------------------------
# Display a usage message
#   $1 - a title
#   $2 - the usage string
#   $3 - a description
function fUsage() {
	printf "$cT\nMrMXF $cI${1}$cX\n"
	printf "$cI-========--========--========--========--========--========-$cX\n"
	printf "$cI $ $cC${2}$cX\n\n"
	if [ "$3" ]; then
		printf "$cT${3}$cX\n"
	fi
}

# ------------------------------------------------------------------------------
# Download from S3 to local
#   $1 - common prefix of the bucket
#   $2 - common options for every sync/copy
#   $3 - common destination file path
#   $4 - any string to perform dryrun
#
#   $DOWNLOAD - an array of commands e.g.
#
#   DOWNLOAD=()
#   DOWNLOAD+=("sync /                      / ")
#   DOWNLOAD+=("cp   public/favicon.ico    favicon.ico ")
#   fDownloadS3  s3://mmh-cache/bot-bdh/staging/hugo-metarex-media\
#                '--include="*"'\
#                /var/www/mySite\
#                DryRun

fDownloadS3() {
	# iterate through SYNCS - print & execute
	PREFIX=$1
	OPTION=$2
	FOLDER=$3

	SRC=()
	DST=()
	VRB=()
	SRCMAX=0
	DSTMAX=0

	for d in "${!DOWNLOAD[@]}"; do
		TOK=(${DOWNLOAD[$d]})    #use bash built-in tokenisation
		VRB+=(${TOK[0]})         # append to verb array
		SRC+=($PREFIX/${TOK[1]}) # append to full source path array
		DST+=($FOLDER/${TOK[2]}) # append to Destination Folder array

		if [[ ${#SRC[$d]} -gt $SRCMAX ]]; then SRCMAX=${#SRC[$d]}; fi
		if [[ ${#DST[$d]} -gt $DSTMAX ]]; then DSTMAX=${#DST[$d]}; fi
	done
	echo "$SRCMAX---$DSTMAX"
	for d in "${!DOWNLOAD[@]}"; do
		VVV=$(printf "%-5s" "${VRB[$d]}")
		SSS=$(printf "%-${SRCMAX}s" "${SRC[$d]}")
		DDD=$(printf "%-${DSTMAX}s" "${DST[$d]}")
		printf "${cC}aws s3$cW $VVV$cC $OPTION$cU $SSS$cF $DDD$cX\n"

		#Dry run if the 4th parameter is set
		if [[ -z "$4" ]]; then
			aws s3 ${VRB[$d]} $OPTION ${SRC[$d]} ${DST[$d]}
		fi
	done
}

# ------------------------------------------------------------------------------
#     fMachine
#       sets cOS to linux | mac | windows | gitpod | unknwown
#       sets cPU to i32   | i64 | a64                      - intel / arm
fMachine() {

	# detect what sort of linux shell we're running in
	case "$(uname -s)" in
	Linux*)
		cOS="linux"
		if ! [ -z "${GITPOD_GIT_USER_NAME+x}" ]; then
			cOS="gitpod"
		fi
		;;
	Darwin*) cOS="mac" ;; # do this before checking for windows
	CYGWIN*) cOS="linux" ;;
	MINGW*) cOS="linux" ;;
	MSYS_NT*) cOS="linux" ;;
	win*) . cOS="windows" ;;
	*) cOS="unknown" ;;
	esac

	# detect what sort of architecturewe're running in
	case "$(uname -m)" in
	x86_64*) cPU="i64" ;;
	amd*) cPU="i64" ;;
	i686*) cPU="i32" ;;
	arm64) cPU="a64" ;;
	aarch64*) cPU="a64" ;;
	i386*) cPU="i32" ;;
	i486*) cPU="i32" ;;
	i586*) cPU="i32" ;;
	*) cPU="i32" ;;
	esac
	export cOS
	export cPU
	#echo "running on $MACHINE with $CPU architecture"
}

# ------------------------------------------------------------------------------
# make some aliases for all the functions (backwards compatibility)
#printing
fnAbort() { fnAbort $1 $2 $3 $4 $5 $6 $7 $8 $9; }    # abort & print
fnError() { fError $1 $2 $3 $4 $5 $6 $7 $8 $9; }     # print ERROR xxx
fnDivider() { fDivider $1 $2 $3 $4 $5 $6 $7 $8 $9; } # print Divider
fnEcho() { fEcho $1 $2 $3 $4 $5 $6 $7 $8 $9; }       # print with line num
fnColors() { fColors $1 $2 $3 $4 $5 $6 $7 $8 $9; }   # print color test
fnInfo() { fInfo $1 $2 $3 $4 $5 $6 $7 $8 $9; }       # print INFO xxx
fnOk() { fOk $1 $2 $3 $4 $5 $6 $7 $8 $9; }           # print OK xxx
fnText() { fText $1 $2 $3 $4 $5 $6 $7 $8 $9; }       # print plain Text
fnUsage() { fUsage $1 $2 $3 $4 $5 $6 $7 $8 $9; }     # print Usage message
fnWarning() { fWarning $1 $2 $3 $4 $5 $6 $7 $8 $9; } # print WARNING xxx
#data
fnGetStack() { fGetStack $1 $2 $3 $4 $5 $6 $7 $8 $9; } # get source line number
fnMachine() { fMachine $1 $2 $3 $4 $5 $6 $7 $8 $9; }   # return cOS & cPU
#Utils
fnWget() { fnWget $1 $2 $3 $4 $5 $6 $7 $8 $9; } # check for wget first
