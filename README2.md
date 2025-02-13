# opentsg-node

The rendering node of the open source [test signal generator][otsg].

## Contents

List of contents here:

- [Description](#description)
- [Installation](#installation)
- [Demos](#demos)
- [Command flags](#command-flags)
- [Logging](#logging)
- [Dev Notes](#dev-notes)

## Description

OpenTSG is a free open source tool for generating test signals for testing
displays and making images. Got some non standard displays to test? Have
a specific colour space you need to work in? You need your images in
a certain file format? Then we have you covered.

OpenTSG has been designed to give you, the people, the power
to make your own test cards. Without having to spend years learning
in depth knowledge about displays to make tests.

We have an extensive library of widgets that you can plug in
and use to suit your needs. Need a test card in two sets of dimensions?
We've got you, OpenTSG scales without changing any of the measurements that
make the tests important. Making sure you can repeat and reuse tests with minimal fuss
and effort.

OpenTSG has the following widgets available

- [AddImage](https://github.com/mrmxf/opentsg-modules/blob/main/opentsg-widgets//addimage/readme.md)
- [Bowtiwe](https://github.com/mrmxf/opentsg-modules/blob/main/opentsg-widgets//bowtie/readme.md)
- [Ebu3373](https://github.com/mrmxf/opentsg-modules/blob/main/opentsg-widgets//ebu3373/readme.md)
- [Fourcolour](https://github.com/mrmxf/opentsg-modules/blob/main/opentsg-widgets//fourcolour/readme.md)
- [FrameCount](https://github.com/mrmxf/opentsg-modules/blob/main/opentsg-widgets//framecount/readme.md)
- [GeometryText](https://github.com/mrmxf/opentsg-modules/blob/main/opentsg-widgets//geometryText/readme.md)
- [Gradients](https://github.com/mrmxf/opentsg-modules/blob/main/opentsg-widgets//gradients/readme.md)
- [Noise](https://github.com/mrmxf/opentsg-modules/blob/main/opentsg-widgets//noise/readme.md)
- [QrGen](https://github.com/mrmxf/opentsg-modules/blob/main/opentsg-widgets//qrgen/readme.md)
- [Resize](https://github.com/mrmxf/opentsg-modules/blob/main/opentsg-widgets//resize/readme.md)
- [TextBox](https://github.com/mrmxf/opentsg-modules/blob/main/opentsg-widgets//textbox/readme.md)
- [ZonePlate](https://github.com/mrmxf/opentsg-modules/blob/main/opentsg-widgets//zoneplate/readme.md)

Don't see the widget you need? Follow the [developer instructions](https://github.com/mrmxf/opentsg-modules/tree/main/opentsg-widgets) to
easily add implement your own widgets.

<!-- Insert image that grabs attention -->

OpenTSG encodes:

- EXR
- PNG
- TIFF
- DPX

Don't see the encoder? Follow the [developer instructions](https://github.com/mrmxf/opentsg-modules/blob/main/opentsg-core/tsg/readme.md) to
easily add implement your own encoders.

This repo is a pure go repo, that uses a domain specific language
to generate the image. If you want to use OpenTSG
with more intuitive and user friendly python wrappers get them here.

To view more technical documentation visit the [modules][mods] repo

## Installation

You can get the latest binaries and source code from the [releases page.][res]

Make sure you have the latest version of Go from the
[official golang source][g1] installed.

Then run the go build command in this repository to compile the code.

```cmd
go build
```

That's all there is to it, have fun making test signals with your new executable.
Don't know where to start? Try one of our [demos](#demos)

## Demos

These are some demos to give ideas of how to generate your own test signals.
This list is not complete for every openTSG feature, please add any demos to the
user demo library that you think would people would enjoy.

The following demos are available

- [EBU 3373](#ebu-3373-walkthrough-demo)
- [Generators](#generators)
- [TSIG Demos](#tsig-demos)

### EBU 3373 walkthrough demo

In this demo we will go through running OpenTSG to generate a widely used
test pattern, and then edit it to show the scaling potential of OpenTSG.

EBU 3373 is a commonly used UHD HDR test pattern, the official
specification can be found [here][3373]. And now it can be made with openTSG!
Lets start by running the ebu json with the following command to make our own
ebu3373 test card

```cmd
./opentsg-node -c ./ebu/loadergrid.json
```

Your output card should be found at [./ebu/ebu0000.png](./ebu/ebu0000.png),
congratulations, you've made your first test pattern.
But what if we want a HD pattern and not this UHD one? Well we can update
the canvas of our test pattern to be HD dimensions.
Update the `"framesize"` fields and the `"outputs"`
field so we don;t overwrite our first test pattern in [./ebu/base.json](./ebu/base.json) to the following.

```javascript
 "outputs": [
        "./ebu/ebu{{framenumber}}-hd.png"
    ],
"frameSize": {
        "w": 1920,
        "h": 1080
}
```

Now run the build command again.

```cmd
./opentsg-node -c ./ebu/loadergrid.json
```

Your output card should be found at [./ebu/ebu0000-hd.png](./ebu/ebu0000-hd.png),
compare your two cards, see how easy it was to scale them.
Try updating even more fields and see what happens, remember to check
the logs folder at `./_logs/` if things don't look like what you expect them to.

### Generators

Generators are widgets that OpenTSG builds at runtime using data files
that are imported. They are a powerful tool for reducing the amount of files
you need to build a test signal.

Read the full demo at [./example/README.md](./example/README.md)

### TSIG demos

TSIG stands for Test Signal Input Geometry and is the OpenTSG tool for building images
that do not fit on a flat screen, for example a house or a spherical wall.
For our demos we take the former object, which comes with an accompanying [obj file](./tsig/objBases/house.obj)

Please check out the following demos.

- [./READMETSIG.md](./READMETSIG.md) - building a house with the EBU 3373 test pattern.
- [./tsig/house-tsig/demo.md](./tsig/house-tsig/demo.md) - building a house with specific TSIG widgets
and more advanced TSIG techniques.

### Building a widget from scratch

Have you completed the other demos and are looking for more of a challenge?
Here we will build a Test signal from scratch, starting with a base then adding fresh widgets as we go.

This demo is not ready for use yet, but watch this space 👀.

## Command Flags

OpenTSG has a host of configuration options when run from the commandline.
These are all configured with the flags, no file configuration is available.

OpenTSG has the following required flags:

- `-c --config` - loads a json or yaml file to be used in configuration e.g, `-c ebu/loadergrid.json`

And the following optional flages:

- `-d --debug` - turns on debug mode, it is off by default.
- `-p --profile`- the aws profile to be used, only required if you are using s3 links and have given any keys.
- `-j --jobID`- the jobID of the openTSG run, if none is provided then a random 16 byte nanoid is used instead.
- `key` -  gitlab, github or AWS key to be used. These are automatically linked to the correct host. Each key
needs to be declared with the field, e.g. `--key key1 --key key2`
- `-o --output` -  the extensions to all files to be saved e.g. `--output mnt/here`
- `-v --version` - the version information of openTSG.
- `-n --note` - the version's deployment note of this OpenTSG version.
- `-s --sversion` - the short version information

## Logging

By default all openTSG, logs are written to `./_logs/`,
where the filename is the job id.

## Dev Notes

If you'd like to contribute to OpenTSG
then please check out the repo that contains the core features
and engine [here][mods]. This contains a lot of technical information
about the features covered in the [demos](#demos) and how you can build your
own OpenTSG integrations.

Please open any issues for bugs or feature requests.

[otsg]:   https://opentsg.studio/  "The official opentsg website"
[g1]:   https://go.dev/doc/install  "Golang Installation"
[res]: https://github.com/mrmxf/opentsg-node/releases "the node releases page"
[mods]: https://github.com/mrmxf/opentsg-modules "the  modules github repo"
[3373]: https://tech.ebu.ch/docs/tech/tech3373.pdf "The ebu 3373 technical specification"
