#!/usr/bin/env bash
#        _
#   __  | |  ___   __ _
#  / _| | | / _ \ / _` |
#  \__| |_| \___/ \__, |
#                 |___/

export bPROJECT=$(basename $(pwd))              # project you're building
export vCODE=$(clog git vcode)                  # referrence code version
export bCodeType="Golang"
export bBASE="OpenTSG"
export bMSG="$(clog git message ref)"            # reference message
export bHASH="$(clog git hash head)"              # hash of head commit
# add a suffix to any build not on the main branch
export bSUFFIX="$(git branch --show-current)" && [[ "$bSUFFIX"=="main" ]] && bSUFFIX=""
