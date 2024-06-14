#                             _                                       _
#   ___   _ __   ___   _ _   | |_   ___  __ _   ___   _ _    ___   __| |  ___
#  / _ \ | '_ \ / -_) | ' \  |  _| (_-< / _` | |___| | ' \  / _ \ / _` | / -_)
#  \___/ | .__/ \___| |_||_|  \__| /__/ \__, |       |_||_| \___/ \__,_| \___|
#        |_|                            |___/
# Create array of the architectures to make during the build
EXE="opentsg"
  gOS=("windows"       "windows"       "darwin"        "darwin"        "linux"         "linux"         "js")
gARCH=("amd64"         "arm64"         "amd64"         "arm64"         "amd64"         "arm64"         "wasm")
 FILE=("wamd-$EXE.exe" "warm-$EXE.exe" "mamd-$EXE"     "marm-$EXE"     "lamd-$EXE"     "larm-$EXE"     "wasm-$EXE")
 cVER=($cE             $cE             $cW             $cW             $cC             $cC             $cU)

fMachine
EXElocal=tmp/lamd-$EXE
[[ "$cOS" == "mac"   ]] && [[ "$cPU" == "a64" ]] && EXElocal=tmp/marm-$EXE
[[ "$cOS" == "mac"   ]] && [[ "$cPU" == "i64" ]] && EXElocal=tmp/mamd-$EXE
[[ "$cOS" == "linux" ]] && [[ "$cPU" == "a64" ]] && EXElocal=tmp/larm-$EXE
[[ "$cOS" == "linux" ]] && [[ "$cPU" == "i64" ]] && EXElocal=tmp/lamd-$EXE
