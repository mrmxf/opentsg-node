#  clog> stage
# short> push executables staging
# extra> Edit script to configure upload.
#                           _
#   __ _   ___   ___   ___ | |_   __ _   __ _   ___
#  / _` | / _ \ |___| (_-< |  _| / _` | / _` | / -_)
#  \__, | \___/       /__/  \__| \__,_| \__, | \___|
#  |___/                                |___/

source clogrc/core/inc.sh
PROJECT=$(basename $(pwd))
fInfo "Project$cH $PROJECT"
# ------------------------------------------------------------------------------

# load in the arrays of variants & the EXE variable
source clogrc/go-variants.sh

# ------------------------------------------------------------------------------
# prepare to tag the local head
TAG=$($EXElocal -v)
MSG=$($EXElocal --note)
LOCAL=$(git tag | grep $TAG)
REMOTE=$(git ls-remote --tags origin | egrep -o "v[0-9]+\.[0-9]+\.[0-9]+" | head -1)

BOT=$MM_BOT
BRANCH="staging"
CACHE="s3://mmh-cache"
REPO=$PROJECT

SRC="tmp/<build articacts>"
DST="s3://mmh-cache/bot-bdh/staging/get/otsgbin"

fYnInput() {
	while true; do
		printf "$1"
		read response
		case $response in
		[Yy]*)
			printf "$cS yes$cX "
			RES=0
			break
			;;
		[Nn]*)
			printf "$cE no$cX"
			RES=1
			break
			;;
		*) fWarning "${cE}Please enter$cC y$cE or$cC n$cE.${cX}" ;;
		esac
	done
}
# ------------------------------------------------------------------------------

# Check the user is happy with tagging
printf "Local tag is ($cE$LOCAL$cX). Remote Tag is ($cC$REMOTE$cX)\n"
fYnInput "push remote tag before uploading to S3 ? yn "

[[ "$RES" == "0" ]] && echo " ... tagging ..." && git push origin $LOCAL #-m "$MSG"

source clogrc/go-variants.sh

# Check the user is happy with uploading
fYnInput "\nUpload $cE${#gOS[@]}$cT files to $DST? yn "

[[ "$RES" == "1" ]] && echo " ... exiting ...\n" && exit 0

echo
#iterate using the same index ($i) for each array
for ((i = 0; i < ${#gOS[@]}; i++)); do
	fInfo "Staging ${cVER[$i]}tmp/${FILE[$i]}${cT}"
	aws s3 cp --quiet --color on ./tmp/${FILE[$i]} $DST/${FILE[$i]}
done
