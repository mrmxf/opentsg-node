#!/usr/bin/env bash
# clog>  build  # build & inject metadata into clog
# extra> push main executables into tmp/
#                             _                                       _
#   ___   _ __   ___   _ _   | |_   ___  __ _   ___   _ _    ___   __| |  ___
#  / _ \ | '_ \ / -_) | ' \  |  _| (_-< / _` | |___| | ' \  / _ \ / _` | / -_)
#  \___/ | .__/ \___| |_||_|  \__| /__/ \__, |       |_||_| \___/ \__,_| \___|
#        |_|                            |___/
# ------------------------------------------------------------------------------
# load build config and script helpers
eval "$(clog project config)"                           # configs in clog.config.yaml
eval "$(clog Inc)"                                      # include clog helpers (sh, zsh & bash)
eval "$(clog Cat core/sh/help-golang.sh)"            # build helpers

fInfo "Building Project$cS $PROJECT $cT using $cC clog Source$cF core/sh/help-golang.sh"

#clog Check
[ $? -gt 0 ] && exit 1
# ------------------------------------------------------------------------------

# ensure tmp dir exists
mkdir -p tmp

branch="$(clog git branch)"
hash="$(clog git hash head)"                                     # use the head hash as the build hash
suffix="" && [[ "$branch" != "main" ]] && suffix="$branch"       # use the branch name as the suffix
app=opentsg-node                                                 # command you type to run the build
title="OpenTSG Render Node"                                      # title of the software
linkerPath="github.com/mrmxf/opentsg-node/src/semver.SemVerInfo" # go tool objdump -S tmp/opentsg-node-amd-lnx|grep /semver.SemVerInfo

fGoBuild tmp/opentsg-node-amd-lnx     linux   amd64 $hash "$suffix" $app "$title" "$linkerPath"
fGoBuild tmp/opentsg-node-amd-win.exe windows amd64 $hash "$suffix" $app "$title" "$linkerPath"
fGoBuild tmp/opentsg-node-amd-mac     darwin  amd64 $hash "$suffix" $app "$title" "$linkerPath"
fGoBuild tmp/opentsg-node-arm-lnx     linux   arm64 $hash "$suffix" $app "$title" "$linkerPath"
fGoBuild tmp/opentsg-node-arm-win.exe windows arm64 $hash "$suffix" $app "$title" "$linkerPath"
fGoBuild tmp/opentsg-node-arm-mac     darwin  arm64 $hash "$suffix" $app "$title" "$linkerPath"

fInfo "${cT}All built to the$cF tmp/$cT folder\n"