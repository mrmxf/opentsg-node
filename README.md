# opentsg-node

The rendering node of the open source test pattern generator.

## Running opentsg-node Via SSH

opentsg-node is designed to be run on a cloud compute instance,  while test
pattern configuration files are made on a low powered gitpod or similar
devlopment enviroment.

The following steps will generate an ec2 that hosts opentsg-node, and include
the methods to interact with it via gitpod.

### Making the ec2

The recommended computing instance is AWS EC2 and can be set up to host
opentsg-node with the following steps.

### Pre EC2 AWS Set up

Before launching the instance some parameters that hold secret tokens need to be
set up first, so the ec2 can intialise correctly without exposing sensitive
information.

go to: AWS Systems Manager > Parameter Store

Set up variables named GITHUB_PAT_TEST and GITLAB_PAT_TEST, which contain the
github and gitlab tokens for accessing the private repository used in opentsg.
The use of the parameter store is to keep sensitive informnation out of the start
up scripts.

### EC2 Parameters

Use the following parameters for setting up the ec2 instance, when launching the
instance from the ec2 console.

#### AMI

ami-08a9192ae4d6049f7

#### Instance type

t2.micro

#### Security

Select the create security group option and allow ssh traffic from anywhere
(0.0.0.0/0).

#### Key Pair

Select an existing .pem key that you have access to or generate a new Amazon RSA
key pair and download them.

#### Role

Generate a new IAM role with the following role policy. The name of the IAM role
is not critical.

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
        "Action": "sts:AssumeRole",
        "Principal": {
            "Service": "ec2.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
        }
    ]
}
```

Assign the additional following policy to your ec2 instance role, this allows
 the ec2 to access the tokens from the parameter store without including them in
 the user data.

  \<userID\> is the user user ID number of the profile that generated
 GITHUB_PAT_TEST and GITLAB_PAT_TEST in the parameter store.
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": "ssm:GetParameter",
            "Resource": [
                "arn:aws:ssm:*:<userID>:parameter/GITHUB_PAT_TEST",
                "arn:aws:ssm:*:<userID>:parameter/GITLAB_PAT_TEST"
            ]
        }
    ]
}
```

#### User data

Userdata is found in the advanced settings of launch instance and is used to run
a set up script when the ec2 is first generated. This script must be copy and
pasted into userdata, ensuring the 3 occurrence of \<GITUSER\> are updated to
the Gitlab and Github user names that the tokens were generated for. It ensures
that everything is installed in the ec2 on set up and that the $PATH variable is
set up for all users to access the opentsg executable, including non interactive
ssh shell users.

```bash
#!/bin/bash

# Install go and extract into /usr/local
if [[ "aarch64" == $(uname -m) ]]; then
  # ARM architecture
  sudo curl -L --output go1.19.4.linux.tar.gz https://go.dev/dl/go1.19.4.linux-arm64.tar.gz
else
  # AMD64 architecture
  sudo curl -L --output go1.19.4.linux.tar.gz https://go.dev/dl/go1.19.4.linux-amd64.tar.gz
fi
tar -C /usr/local -xzf go1.19.4.linux.tar.gz
# then set adding go to the path

# insert this section at the start of /etc/bash.bashrc
# this allows the noninteractive ssh commands to still utilise /opentsg/
# and other needed paths
read -r -d '' PATHEXPORT << EOM
if [ -f ~/.bashrc ]; then
  . ~/.bashrc
fi

export PATH="\$PATH:/usr/local/go/bin:/opentsg/"
EOM
# append to the start of the file so it runs before the noniteractive shell propmt cancels everything
echo "$PATHEXPORT" | cat - /etc/bash.bashrc  > temp && mv temp /etc/bash.bashrc
# include the path for interactive users
echo export PATH="$PATH:/usr/local/go/bin:/opentsg/" >> /etc/profile
# export for the root profile
export PATH="$PATH:/usr/local/go/bin:/opentsg/"

#extract the tokens and then write to netrc
GITLAB_PAT=$(aws --region=eu-west-2 ssm get-parameter --name 'GITLAB_PAT_TEST' --query 'Parameter.Value')
GITHUB_PAT=$(aws --region=eu-west-2 ssm get-parameter --name 'GITHUB_PAT_TEST' --query 'Parameter.Value')
# remove quotes from the tokens
GITLAB_PAT=`sed -e 's/^"//' -e 's/"$//' <<<"$GITLAB_PAT"`
GITHUB_PAT=`sed -e 's/^"//' -e 's/"$//' <<<"$GITHUB_PAT"`

#Add the two passwords for the git machines
read -r -d '' gitAccess << EOM
machine gitlab.com login <GITUSER> password $GITLAB_PAT

machine github.com login <GITUSER> password $GITHUB_PAT
EOM
#Generate the netrc for the different profiles
echo "$gitAccess">/home/admin/.netrc


# apt-gettable programs with update apt-get
sudo apt-get update
echo Y | sudo apt-get install git-all
# gcc
echo Y | sudo apt install build-essential


# OPEN TPG
# make a folder everyone can use
mkdir /opentsg/
sudo chmod -R a+rwx /opentsg/
# install opentsg
git clone --depth 1 -b dev "https://<GITUSER>:$GITLAB_PAT@gitlab.com/mmTristan/open-tpg.git" /opentsg
cd /opentsg/
# valid home is needed to make go along with the $HOME/.netrc
export HOME="/root/"
echo "$gitAccess">$HOME.netrc
# declare when to use .etrc for downloads
go env -w GOPRIVATE=gitlab.com/*,github.com/*
go build

# allow /mnt/ to be accessed by anyone
sudo chmod 0777 /mnt/
```

After building the ec2 instance, connect via ssh and ensure the following
programs and set up configurations are present:

- [ ] go
- [ ] git
- [ ] gcc
- [ ] .netrc in $HOME
- [ ] opentsg-node
- [ ] a /mnt/ folder that can be written to.

If one or more of these are missing the log can be checked with nano
/var/log/cloud-init-output.log , to help identify any bugs.


Take note to ensure you have all of these before running opentsg-node via ssh.

- [ ] ec2 address
- [ ] fully configured ec2 instance
- [ ] .pem key
- [ ] default user name (admin is the default but it may have changed)

### SSHFS

Install [sshfs](https://github.com/libfuse/sshfs), a way to mount a ec2 folder
on your local file system, so that the ec2 instance can access the json files
and you can view the generated images.

```bash
sudo apt update
sudo apt install sshfs
sshfs <username>@<ec2.address>:/mnt/ ./mnt -o IdentityFile=<full/path/to/key>.pem
```
you can include the flag ``` -odebug,sshfs_debug,loglevel=debug ``` for debugging.

 <username>@<ec2.address>:/mnt/ is the server and server folder mount location.
 ./mnt/ is the folder mount location on your local system. \<path/to/key\>.pem
 is the path to the access key file. Ensure you are mounting to an empty folder
 to prevent overwriting files.

### running opentsg-node

running open tpg exporting the path. Adding a ```--output /folder/location```
flag which changes where files are to be saved from, as ssh connects from the
root of the ec2, not the mounted folders position. This is because opentsg-node saves
relative to where the program is called from, not to the config files location.

Run opentsg-node with as many/few commands as you prefer, ensure the generated images are saved in a folder you can access.

For the example copy the ebu folder into the mounted ec2 instance and run the command below, this will generate an ebu test image in the /mnt/ebu/ folder titled ebu0000.png and show any errors that may occur.

```
ssh -i <path/to/key>.pem <username>@<ec2.address> 'opentsg-node --c /mnt/ebu/loadergrid.json --debug --log stdout --output /mnt/ebu/'
```

To generate a 1000 ebu images to test performance and cpu usage, change the ebu folder out for ebu_long and change the config file to be /mnt/ebu_long/loadergrid.json, this will generate a 1000 identical images labelled from ebu0000.png to ebu0999.png.

## Installation (pre-release)


Create a GitLab **Personal Access Token** for the private dev repos. store it in the ENV variaable `GITLAB_PAT`.
```
# install token and update dependencies
./init.sh
go mod tidy
```

Before building the program ensure you have all the dependencies by running `go mod tidy`. Running `./run.sh` will automatically build and run opentsg-node.

To compile opentsg-node the following commands must be run, in order to have the correct configuration set up.

```
go build opentsg-node.go
export LD_LIBRARY_PATH=/workspace/open-tpg/lib:$LD_LIBRARY_PATH
```
This will generate a opentsg-node executable file, and link it to the so libraries for saving .sth files. The export LD_LIBRARY_PATH is no longer required.

## Running the program and flags
To run the program the following command should be typed, the opentsg-node executable will vary depending on the operating system used and the example below is for a linux system.

```
./opentsg-node --c filename.json
```


### --c
This loads a json file to be used in configuration e.g, `--c ebu/loadergrid.json`

ebu/loadergrid.json gives an idea of a typical JSON file.

There are no default settings, if a value is not called in the json then the image will not be generated. Variable names are case sesnsitive and should match the examples below.

### -ouput
-output changes the output location of saved images e.g.
`-output path/to/folder/`
used with the file example.png, will result in the file being saved at path/to/folder/example.png. The default save location is the location opentsg-node was called from.

### -profile
-profile gives the name of an aws profile to search for when initialising the program. If no profile is given then default is searched for.

### -key
-key is used for passing keys to access gitlab, github and aws sources. Key needs to be called for each indiviual key and the keys are automatically assigned to their respective domains.
e.g.
```
./opentsg-node --c filename.json -key gitlabtoken -key awsdomain -key awsprivate -key awskey
```

### -debug
-debug gives the full error message and enables metadata.

### examples

Run the following command to generate a set of ebu 3373 bars all from open tpg.

```
./opentsg-node --c ebu.json --log stdout
```


## Error logging
To log the error from opent tpg use the log flag e.g.

```
./opentsg-node --c filename.json -log stdout
```

The available log options are:
- stdout - print the errors to stdout
- stderr - print the errors to stderr
- file - the errors are saved in a opentsg_date.log file
- file:path/to/logfile.log - generate a custom name and path for the log file

if no option is provided then no errors are output, apart from fatal errors.

### Error code format

An example error code is 0001_E_RAMPS_MULTISTRIPE_0124.

This is broken down into Framenumber_errortype_widget_alias_errorcode

- Framenumber is the frame the error occured on
- Error type is either an E for Error of F for fatal. Fatal errors stop opentsg-node
- Widget is the widget that the error occured in.
- Alias is the alias that was being used from the factory that the error occured in.
- Error code is the error that occured. Please check the lookup table for more exact information on the error.

## Json Factories

Checkout the json schemas for each indiviual factory type to get an idea of how to build the individual factory json. Each json object after initialisation is recusrively built from the information from the preceding factories. For each json object any declared aliases are applied to the factory alias and the image is generated using those updates to the json objects. These updates reset for each json object.

## Grid Description
The test patterns are set up to all use grids, each json item needs to have its grid location specified as shown in test.json. Every factory apart from frame counter and qr code require the grid object to determine their position on the test chart.


The x coordinates start at A and increase from left to right, if there are 27 columns thenn the range of cooridantes would be A:AA. The number of columns is delcared in the canvas options widget.
The y coordinates start at 0 and increase from the top to bottom of the chart. The number of rows is delcared in the canvas options widget.
The top left quadrant has a position of A0.

Each json section requires the grid position to be declared as such:
```
      "grid": {
        "location": "a3:p7",
        "alias": "bottom"
      }
```

The alias is not required.
### Alternate R0C0 method

There is an alternate method for declaring positions. This is based on row and column positions and declared in the form RNumberCNumber, e.g. R3C28

Each json section requires the grid position to be declared as such:
```
      "grid": {
        "location": "R0C0:R10C6",
        "alias": "bottom"
      }
```
## Description

opentsg-node is a testpattern generator, it has a variety of widgets you can add in a modular fashion to a base testcard.


running
```
go get -v  golang.org/x/tools/cmd/godoc

godoc -http=:6060
```
will show the go documentation of all of the repos

## File Signatures
CRC32 is calculated using the IEEE polynomial.

CRC16 is calculated using the IBM polynomial.

### Validating Signatures

To ensure the hashes were generated by the Mr MXF opentsg-node run the following commands, to get the public key of the signature and validate the file.

for bash:
`curl -s -o tmp.pem https:/staging.mrmxf.com/get/public.pem ; openssl dgst -sha256 -verify tmp.pem -signature tifftest.png.txt.sha256 tifftest.png.txt`
for windows:
`curl -s -o tmp.pem https://staging.mrmxf.com/get/public.pem && "C:\Program Files\Git\usr\bin\openssl" dgst -sha256 -verify tmp.pem -signature tifftest.png.txt.sha256 tifftest.png.txt`

Successful runs result in an output of `Verified OK`.
Unseccessful outputs return a `Verification Failure` - This file was not generated by MR MXF and the contents of the file are taken to be false.


## Json Factory Formatting

The following input widgets are used in opentsg-node, the input json must follow this format.

The include object is an array of objects that contain a uri and a name for the object.

The following is an example input file, the "uri" can contain strings for http sources, local files which can contain widgets or other factory jsons.

Args can be parsed, where the argument is only relative to the json factory it is declared in. They can be parsed from a parent to child in the create function with the following syntax ```"target":{"argumentname":"argument"}```. The arguments can be susbtituted in any string using mustache notation {{argument name}}.



### The create object

For the first json file import the create array is the frame order, where the 0th object is the 0th frame. For subsequent imported jsons the create array is the order in which widgets are intialised where every object is intialised in create, regardless of its array position.

Furher more updates can be applied via the create object as demonstrated below. Where the ```"update":"value"``` is applied within the canvas.

precompute - run the command ```./opentsg-node --c example/sequence.json --debug --log stdout``` for an example of a program run using data.

```
{
    "include": [
        {
            "uri": "./verde_factory/canvas.json",
            "name": "canvas"
        },
        {
            "uri": "./verde_factory/qr.json",
            "name": "qr"
        },
        {
            "uri": "./verde_factory/squarezone.json",
            "name": "zone"
        }
    ]
"create":{
    "canvas": {"update":"value"}
}

```
### The generate object

Generate uses a base widget to generate several widgets from data, this is to reduce the need to declare every widget individually and to update the widgets with several different data inputs.

In the following example the action within generate, has an key of pyramid, this tells generate to use the widget named pyramid.
Then the data.{{swatchParams}} can be split into the data (data) to be used, and the data field ({{swatchParams}}) to extract the data from, it is expected the data json has many different fields to prevent several imports being used. The data.{{swatchParams}} : ["grid.location","backgroundcolor"] then has an array of the field keys to update on the original pyramid widget.

The names [{"R":"[:]"}, {"C":"[:]"}, {"B":"[:]"}] is used to give the name of each dimension of the data and which values in the dimension to use. In this example the name generated will follow the format of blueR0.C0.B0 .


```
  "include": [
      { "uri": "pyramid.json", "name": "pyramid" },
      { "uri": "pyramid-data-new.json", "name": "data" }
    ],
    "args": [
      {
        "name": "swatchParams",
        "type": "string",
        "doc": "string index of imported swatch"
      },
      {
        "name": "frameNumber",
        "type": "number",
        "doc": "number of the current frame - remove framecounter as it is a magic string etc"
      }
    ],
    "generate": [
      {
          "name": [{"R":"[:]"}, {"C":"[:]"}, {"B":"[:]"}],
          "action": {
           "pyramid" : {
           "data.{{swatchParams}}": ["grid.location","backgroundcolor"]}
          }

      }
    ]

```

### Middleware
This is currently not here but will be added later
After the factory include section of a json a middleware section can be included to run on certain conditions, it follows the layout below.

```
"middleware":{
      "anyOf" : ["framecount(0,10)"],
      "action" : { }
}
```


Anyof is an array of the conditions to test against. If any (all at the moment) pass then the action is taken.
The action object matches the format of the update objects used throughout the config.





### Templates



### canvas options

The canvas options factory has the type "builtin.canvasoptions" and contains the following keys

- name - this specifies the file names of the generated image, it is an array and must match the number of outputs. It follows this convention:

    multiramp-BD-CR-RES

    BD = max bitdepth - usually 16b or 12b or 10b or hf

    CR = color range - pc or tv or aces

    RES = resolution - hd or 2k or uhd1 or 4k or uhd2 or 16k

files can be saved as a dpx, tiff, png, 7th or csv.


```
"name": ["multiramp-12b-pc-hd.tiff",multiramp-12b-pc-hd.png"]
```
- filedepth - this the bit depth of the file to be saved, 8,10,12 and 16 are valid values. If no values are given then the default value is 16
```
"filedepth": 8
```
- linewidth - this is the width of the grid lines in pixels
```
"linewidth": 0.5
```
- gridColumns - this is the number of the columns to be used as a grid.
```
"gridColumns" : 16
```
- gridRows - this is the number of the rows to be used as a grid.
```
"gridRows" : 16
```

- framesize - this is comprised of a width (w) and height (h) and specifies the image size.
```
"frameSize": {
        "w": 4096,
        "h": 2160
    }
```
- textColor - the colour of the labels as a 8 bit or 4 bit hex code (#xxxxxx) and can be declared with or without the alpha channel. Alternativley it can be called using the css style.
```
"textcolor": "#C2A649"
or
"textcolor": "rgb(253,34,56)"
```

- metadata or frame analytics creates a yaml file with the specified data. Configuration shows the complete widget set up and input. Average colour shows the average colour of the canvas.

```
    "frame analytics" : {
        "configuration": {"enabled":true},
        "average color": {"enabled":true}
      }
```
### ramps

The ramps factory has the type "builtin.ramps" and contains the following keys for generating the ramps. The ramps are built in the order of group divider, then alternating layers of stripe and inter stripe dividers.


- depth - the bit depth that the inital rgb values for white,black and ramp start are specified for
  - 12 bit has a range of 0-4095
  - 10 bit has a range of 0-1023
  - 8 bit has a range of 0-255
  - 4 bit has a range of 0-15
```
"depth": 8
```
- minimum - the minimium rgb value for the ramp
```
"minimum": 0
```
- maximum - the maximum rgb value for the ramp
```
"maximum": 255
```
- fillType - the way the ramps fill the image. "truncate" cuts the pixels off if the given range of the ramps is narrower than the image. "fill" shortens the ramps to fill the image giving a full range, however this is not pixel accurate for all bit depths. The default behaviour is to truncate the ramps.
```
"fillType":"fill
```
- angle - the angle of the plate in radians or degrees, angles that at not at 90 degrees can not be guranteed to be pixel accurate.
```
"angle" : 136.7

Or

"angle" : "π*1/2"
Or

"angle" : "π*345"
```
- text contains all of the objects for the label text. Each value does not need to be called to generate text.
  - xposition- the text postion as either, left, right or center of each stripe.
  - textyposition - the text position as either top middle or bottom of each stripe.
  - textcolor - the color of the text, th
  - textheight - the size of the text as a percentage of the height of the stripe.

```
"text":{
    "textxposition": "center",
    "textyposition": "top",
    "textcolor":"#C2A649",
    "textheight":20
}
```

- stripes contains all of the objects for generating the ramps. It contains objects for the header, stripes and interstripes.
  - groupHeader contains the  color and height properties of the group header.
    - color is an array of strings for the color, only one color is allowed.
    - height is the height of the group relative the stripes and stripe dividers.
  - interstripes contains the  color and height properties of the interstripe dividers.
    - color is an array of strings of the color, if more than one color is given the divider alternates through the colors based on the pixel change of the next stripes.
    - height is the height of the stripedividers relative the stripes and header.
  - ramps contains the height, bitdepth, fill type and labels of the stripes.
    - fill can be gradient or constant. If the gradient is used then the ramp will gradually change colour across the iamge.
    - bit depth is an array of the stripe bit depth for each group. The length of this array matches the number of stripes per group. Only 4,8,10 and 12 bit depths can be chosen.
    - labels is an array of strings to be placed on each stripe. Each label index matches the bitdepth index
    - height is the height of the stripes relative the groupheader and stripe dividers
  - Rampgroups contains color, start position and direction of the gradient of the stripes. Each object is a group of stripes. The stripes are added in alphabetical order of the names. In the example below the order is "bluePos","grayNeg","greenPos" and "redPos".
    - color is the color of the stripe
    - direction is if the ramp moves from bright to dark (-1), or dark to bright (1)
    - rampstart is the rgb value of the stripe to start on. This matches the bitdepth of the depth variable. e.g. 12 bit depth gives a rampstart range from 0 to 4095
```
 "stripes": {
        "groupHeader": {
            "color": [
                "white"
            ],
            "height": 6
        },
        "interstripes": {
            "color": [
                "black",
                "white"
            ],
            "height": 2
        },
        "ramps": {
            "fill": "gradient",
            "bitdepth": [
                12,
                10,
                8,
                4
            ],
            "labels": [
                "12b",
                "10b",
                "8b",
                "4b"
            ],
            "height": 6,
            "rampGroups": {
                "redPos": {
                    "color": "red",
                    "rampstart": 0,
                    "direction": 1
                },
                "greenPos":{
                    "color": "green",
                    "rampstart": 0,
                    "direction": 1
                },
                "bluePos":{
                    "color": "blue",
                    "rampstart": 2815,
                    "direction": 1
                },
                "grayNeg":{
                    "color": "gray",
                    "rampstart": 2815,
                    "direction": -1
                }
            }
        }
```

### zoneplate

The zoneplate factory contains all the values for generating the zoneplate. The type is "builtin.zoneplate".

- platetype -  the type of zone plate generated, the types are available "circular","sweep" and "ellipse"
```
"platetype": "sweep"
```
- angle - the angle of the plate in radians or degrees
```
"angle" : 136.7

Or

"angle" : "π*1/2"
Or

"angle" : "π*345"
```
- startcolor - the initial color of the zone plate, the available colors are "black", "white" and "gray"
```
"startcolor" : "white"
```
- mask - triggers a mask to be applied over the zone plate, the available options are "circle" and "square"
```
"mask" : "circular"
```

### Addimage

addimage contains all the values for adding an image to the test chart, only 16 bit image can be imported. The image is resized to fill the size of the grid location specified. The type is "builtin.addimage".

- image -  the names of the file to be imported, only png and tiff files are available to be imported.
```
"image": "circle.png"
```
- imageFill - how the image is scaled to fit on the card
  - "y scale" - scales the image in the y direction, if the width is larger than the height the image is cut off at the boundaries.
  - "x scale" - scales the image in the x direction, if the height direction is larger than the width it is cut off at the boundaries.
  - "xy scale" scales the image in the smaller of the x or y direction to ensure the image fits within the grid boundaries.
  - "fill" stretches the image boundaries to fit the grid, this is the default behaviour.
```
"imageFill":"y scale"
```
### Noise

noise contains all the values for generating image noise on the test chart. The type is "builtin.noise".

- minimum - the minmium 12bit rgb value for the noise to take.

```
"minimum": 0
```

- maximum - the maximum 12 bit rgb value for the noise to take.

```
"maximum":4095
```
- noisetype - the type of noise to be generated, only "white noise" can currently be generated.

```
"noisetype":"white noise",
```

### Text box

text box contains all the values for generating text boxes. The type is "builtin.textbox"

- text - text is an array of strings where each item in the array is a newline.

```
 "text": ["My header"]

 or

  "text": ["my first line","my second line"]
```
- font - font is the font of the text, an inbuilt font of "header", "title" or "body" can be used. Or a the path to a local .ttf file or http source can be used.

```
"font": "title"

or

"font": "./path/to/font.ttf"

or

"font": "https://get.example.com/myfont.ttf"
```

- bordercolor - brodercolor is the colour of the border and has the same colour designation as textcolor in canvas options.
```
"bordercolor": "#C2A649"
```
- textcolor - textcolor is the colour of the border and has the same colour designation as textcolor in canvas options.
```
"textcolor": "#C2A649"
```
- backgroundcolor - backgroundcolor is the colour of the border and has the same colour designation as textcolor in canvas options.
```
"backgroundcolor": "#ffffff"
```

- bordersize - bordersize is the width of the border as a percentage of the overall height of the text box. The maximum value is 0.45
```
"bordersize": 0.02666
```

### qr code

qr code contains all the values for generating qr codes. The type is "builtin.qrcode"

- code - code contains the string of the text to be encoded as qr code

```
"code":"https://mrmxf.io/"
```
position - position is the x y location of the top left corner of the qr code. The x y values are a percentage value of the grids width and height, for x and y respectively, they range from 0 to 100. If left empty then it is placed in the top left corner of the grid it has been assigned.
```
"position":{
    "x":100,
    "y":50
}
```
size - size is the width and height of the qr code as a percentage of the grid it occupies. from 0 to 100%, if left empty than this will be the default size of the qr code. The height must match the width.

```
"size":{
    "height": 40,
    "width": 40.5
}
```


### frame counter
frame counter contains all the values for generating the frame counter. The type is "builtin.framecounter".

- framecounter - framecounter is a boolean to decide if the frame counter is being added for this frame.
```
"framecounter":true
```
- backgroundcolor - backgroundcolor is the colour of the border and has the same colour designation as textcolor in canvas options. The default option is a light semi transparent grey
```
"backgroundcolor":"#00000000"
```
- textcolor - textcolor is the colour of the border and has the same colour designation as textcolor in canvas options. The default option is black
```
"textcolor": "#C2A649"
```

- fontsize - fontsize is the font size as a percentage of the height of the grid, from 0 to 100%.If the height is greater than the width of the image than additional scaling of the font will occur.
```
"fontsize" : 23.3
```

- font - font is the font of the text, an inbuilt font of "header", "title", "pixel" or "body" can be used. Or a the path to a local .ttf file or http source can be used.

```
"font": "title"

or

"font": "./path/to/font.ttf"

or

"font": "https://get.example.com/myfont.ttf"
```

- position - position is the x y location of the top left corner of the frame counter, in respect to the grid.The x y values are a percentage value of the grids width and height, for x and y respectively. Or an alias can be used to place the counter in one of the corners, the alias are: "bottom right","bottom left","top left" and"top right".
```
"position":{
    "x":0,
    "y":50
}

or

"position":{
    "x":36.5
}

or

"position":{
    "alias":"bottom right"
}
```


### EBU 3373 Bars
The bars modules contains a type of "builtin.ebu3373/bars" and a location.

### EBU 3373 Luma
The luma modules contains a type of "builtin.ebu3373/luma" and a location.

### EBU 3373 Nearblack
The nearblack modules contains a type of "builtin.ebu3373/nearblack" and a location.

### EBU 3373 Saturation

The bars modules contains a type of "builtin.ebu3373/saturation".

- colors - colors is an array of red, green and blue, all 3 values can be chosen and are placed in the order of the array.
```
"colors": [
    "red",
    "green",
    "blue"
],
```

### EBU 3373 Two Sample Interleave
The Two Sample Interleave (twosi) modules contains a type of "builtin.ebu3373/twosi" and a location.

### Four Colour

The bars modules contains a type of "builtin.fourcolor".

- colors are the colors to be used by the four colour algorithm in order. The number of colours declared is the number of colours used by the algorithm, in the order declared. At least four colours must be used. A palette of 5 colours e.g. `"colors" : ["#FF0000", "#00FF00", "#0000FF", "#00FFFF", "#FF00FF"]` is recommended for larger images as the four colour palette may result in a timeout error.

```
"colors" : ["#FF0000", "#00FF00", "#0000FF", "#00FFFF", "#FF00FF"]
```

### Geometry Text


The bars modules contains a type of "builtin.geometrytext".

- TextColor is the color of the label and has the same colour designation as textcolor in canvas options. There is no default option.

```
"textColor" : "#FFFFFF",
```


## Internal design and jargon

opentsg-node is designed to generate all the json information on a per frame basis. With the frame information being discarded after it has been generated.
The widgets and factories are declared in the create array of a factory, where each position in the create array of the initilisation json is a frame. In all the children factories, every create object is used in the array, and the order of the array is used to ensure the positioning of the objects will remain constant. The generate array order is also preserved.

Open tpg runs in two stages:

- Init
  - parse the the first object as a factory.
  - Open the jsons declared in include and sort if these are widgets or more factories. If it is a factory then it recurivley repeats the process until all inlcude files are opened,files are opened in the order they are declared.
- Run
  - Run the frame position of create in the init file. This generates widgets in the array order they were declared in the factory. With the arrays in depth first order.
  - Within each factory the generate objects array of a factory is run first, then the create array.
  - Generate generates json widgets based on the data input and only updates the specified fields. The names for each depth are given by the user and generated based on their array positions.
  - Create objects either run recursively to another factory or generate a widget with the specified map updates.


### Z order

The z order is the running order of each widget and runs as a depth first order. This will run down each of the tree branch in order. Make a diagram. The position is generated on each run as the number of widgets can vary.

Runs through each array position in the create, if order is import ensure each object is in a seperate array position, where multiple objects are in the same array position in the create field then the order they are generated will be random.


### Jargon


- Factory - the name for a json input file that follows the input file schema.
- Parent - a factory that contains an include that contains more factories.
- Child - a factory within a factory.
- Widget - a json object that generates images in relation to the input.
- Sequencer?



Frame is the parent of frame.example.pyramid and example is the parent of pyramid. Pyramid and example are both children


### Args scope

Arguments from a parent are called like this ```"frame": {"swatchType":"green"}``` where swatchtype is the name of the argument. This follows the format of ```"targetName": {"argumentName":"argument"}```

All arguments are treated as strings for substitution with strings mustaches.

Arguments are passed only from a parent to a child. They are not passed recurisvely to nested children.


### Data Format

object name, which then has dimensions and data[:], which is formatted as a single array representing a multidimensional array.
The order of which goes a1b1c1, a1b1c2 a1b1c3 a1b2c1 for any n dimensional array. These are calculated from the dimension specified in the data section. Make sure the dimensions and number of values match, otherwise the data will not be processed!

Choosing the data arrays with the following types, this follows python syntax :
- [:] gives the entire array
- [2:] takes all values from the 3rd position (arrays start at 0)
- [:2] takes all values up to and not including the 3rd position
- [1:3] takes all the values from the 1st to the 3rd, not inlcuding the third position.

Each array position in the nth dimension of the data being parsed and in the example below will follow the naming convention R{{number}}.C{{number}}.B{{number}}


```
"name": [{"R":"[2:]"}, {"C":"[1]"}, {"B":"[:]"}],

```

Action is designed so that it gives a widget to be updated and then the data source and the data field of that data. Then an array of the fields to be updated, so that different fields can be updated on different runs.

```
     "action": {
           "widgetbase" : {
           "data.datafield": ["update fields","update fields"]}
          }


     "action": {
           "pyramid" : {
           "d.{{swatchParams}}": ["grid.location","backgroundcolor"]}
          }
```



### Hierarchy

When updating groups of widgets there are two main methods of arrays and dotpaths. Array paths take precedence over dotpaths. Dotpath changes run in the order of the level they were declared in. The

A dotpath of path.onelayer.twolayer.threelayer will run before onelayer.twolayer, because it was declared in a higher level.


The Dot paths and arrays are sorted so that dot paths run first and runs as part of the initial frame generation process. Arrays after the initial generation of all the widgets and apply their updates as they depend on all the widgets being generated for their array position. The array updates run in the order they were declared, when an array target includes a dotpath, e.g. target.nest[0],  this will be ran before an array targeting the same layer e.g. target[0:2][0]

Dot paths can follow the format of ```"alias.aliasWithinScope.repeat"```. If this leads to a factory then all inputs are updated within the factory and if it leads to a single item then the object is updated.

Array paths follow the regex of ```^[\\w]{1,255}(\[[\d]{1,3}:{0,1}[\d]{0,3}\]){1,}$``` and will have infinite dimension depth. The arrays start at 0 and are inlcusive.

### Colour Strings Format
Formats and their usages

4 Bit formats:
- #RGB - hexcode format
- #RGBA - hexcode format with alpha channel

8 Bit formats:
- #RRGGBB - hexcode format
- #RRGGBBAA - hexcode format with alpha channel
- rgb(R,G,B) - css format with values from 0-255
- rgba(R,G,B,A) - css format with alpha channel values from 0-255

12 Bit formats
- rgb12(R,G,B) - css format with values from 0-4095
- rgba12(R,G,B,A) - css format with alpha channel values from 0-4095
