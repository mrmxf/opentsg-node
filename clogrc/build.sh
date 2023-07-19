# usage> build
# short> build & inject metadata into clog
# long>  build & inject metadata into clog
#                             _
#   ___   _ __   ___   _ _   | |_   _ __   __ _
#  / _ \ | '_ \ / -_) | ' \  |  _| | '_ \ / _` |
#  \___/ | .__/ \___| |_||_|  \__| | .__/ \__, |
#        |_|                       |_|    |___/

# export the commit ID for the build

# usage> build
# short> build & inject metadata into clog
# long>  build & inject metadata into clog
#        _
#   __  | |  ___   __ _
#  / _| | | / _ \ / _` |
#  \__| |_| \___/ \__, |
#                 |___/
# export the commit ID for the build

source clogrc/core/inc.sh

GOCODE=$(cat <<-EOM
package versionstr  //auto-generated (versionstr.go)
const build = "$(git rev-list -1 HEAD)"
const date = "$(date +%F)"
EOM
)
echo "$GOCODE" > versionstr/versionstr-build-id.go

fnInfo "Building ${cE}_win${cT}msgtsg.exe (${cE}amd64${cT}) with metadata"
GOOS=windows  ;   GOARCH=amd64      ; go build -ldflags "-X main.UseLinkerOverrides=true"  -o _winmsgtsg.exe

fnInfo "Building ${cW}_la${cT}msgtsg      (${cW}arm64${cT}) with metadata"
GOOS=linux    ;   GOARCH=arm64      ; go build -ldflags "-X main.UseLinkerOverrides=true"  -o _lamsgtsg

fnInfo "Building ${cC}_lx${cT}msgtsg      (${cC}amd64${cT}) with metadata$cX"
GOOS=linux    ;   GOARCH=amd64      ; go build -ldflags "-X main.UseLinkerOverrides=true"  -o _lxmsgtsg

fnInfo "Linking  ${cC}_lx${cT}msgtsg to ${cC}./clog$cX"
rm msgtsg
ln _lxmsgtsg msgtsg

