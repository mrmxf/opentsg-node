# opentsg-node

The rendering node of the open source [test signal generator][otsg].

## Contents

List of contents here:

- [Description](#description)
- [Installation](#installation)
- [Flags](#flags)
- [Demos](#demos)

## Description

OpenTSG is a free open source tool for generating test patterns.

This repo is the pure go repo, if you wamt python wrappers use them here.

## Installation

Make sure you have the latest version of Go from the
[official golang source][g1] installed.

Then run the go build command to compile the code.

```cmd
go build
```

## Flags

OpenTSG has the following flags:

- `--c` - loads a json or yaml file to be used in configuration e.g, `--c ebu/loadergrid.json`
- `--debug` - turns on debug mode, it is off by default.
- `--profile`- the aws profile to be used, only required if you are using s3 links and have given any keys.
- `--jobID`- the jobID of the openTSG run, if none is provided then a random 16 byte nanoid is used instead.
- `key` -  gitlab, github or AWS key to be used. These are automatically linked to the correct host.
- `--output` -  the extensions to all files to be saved e.g. `--output mnt/here`
- `--log` - the output destination of the log, the default is to not log anything.
  - `stdout` - output to stdout.
  - `stderr` - output to stderr.
  - `file` - output to a file who's file name is in the format `2006-01-02_150405`.
  - `file:example` - a specifcally named file, must match the regex of `^file:[a-zA-Z0-9\.\/]{1,30}\.[lL][oO][gG]$`
- `version` - the version information of openTSG.
- `note` - the version's deployment note of this OpenTSG version.
- `v` - the short version information

## Demos

These are some demos to give ideas of how to generate your own patterns.

The following demos are available

-
-
-

### verde demo and walkthrough

cannabalise into my first tsg

### EBU3373 walkthrough demo

```cmd
./opentsg-node --c ./ebu/loadergrid.json --debug --log stdout
```

### Artkey demo

explain the premise and remake

### TSIG demo

link to the seperate TSIG readme

## Technical stuff

If you'd like to contribute to OpenTSG
then please check out this repo that contains the core features
and engine.
Start as this readme to find out more about the internal workings
and what can be changed.

## Widget inputs - link to the widgets

[otsg]:   https://opentsg.studio/  "The official opentsg website"
[g1]:   https://go.dev/doc/install  "Golang Installation"
