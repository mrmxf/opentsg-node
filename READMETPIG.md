# TPIG

TPIG stands for Test Pattern Input Geometry. It is used for mapping flat images to 3d screens.

## Using a TPIG with OpenTPG

The tpig geometry combines with the grid system of OpenTPG. Where the grid coordinates contain all the positions of TPIG geometry that lie under a grid coordinate, this allows us to place patterns on the TPIG using a scalable system. The grid system will be demonstrated with the demo later in the readme.

In this demo, we use a 16x16 grid to demonstrate the layout on grid and tpig geometry. The grid locations range from A0 to P15 or R1C1 to R16C16 depending on your preferred method.


## Demo 

This demo runs opentpg, generating the four/five colour algorithm, for TPIG geometry of the Las Vegas Sphere and the standard grid geometry of Opentpg. Both use a 16x16 grid to map the four colour widget to the test pattern.

To get started run `go build` on a linux system. {BRUCE NOTE to do so on windows we need to remove the sth saver/ change it for the windows version which is not yet made}


Then run this command `./opentpg --c tpig/gridexample.json --log stdout --debug` to generate the OpenTPG grid four colour example. Run this command `./opentpg --c tpig/tpigexample.json --log stdout --debug` to generate the Las Vegas Sphere four colour test pattern. The generated images will be in the tpig/example folder and the TPIG pattern will have produced the carved pictures as well as the flat image. Please note the TPIG example will take a few minutes to run.


The size of the TPIG canvas supersedes the base canvas size, which is why the demo produces two sized different images. 

### What is the difference between the input files? 

One has an test pattern input geometry (TPIG) file in the canvas widget, that is the widget that tells opentpg the set up for the test pattern e.g. how big the image is, any background colours and what the file names are to save.

The only difference between the set up of the example files is the canvas widget has the geometry and a new save name for the generated test pattern.

### The Four Colour Widget

Has a type, location and a colour pallette. 

Type tells OpenTPG what type of widget the JSON information relates to.

```
"type": "builtin.fourcolor"
```


colors are the colors to be used by the four colour algorithm in order. The number of colours declared is the number of colours used by the algorithm, in the order declared. At least four colours must be used. A palette of 5 colours e.g. `"colors" : ["#FF0000", "#00FF00", "#0000FF", "#00FFFF", "#FF00FF"]` is recommended for larger images as the four colour palette may result in a timeout error.

```
"colors" : ["#FF0000", "#00FF00", "#0000FF", "#00FFFF", "#FF00FF"]
```

Grid is the grid location on the test pattern that this widget applies to. "A0:P15" is the whole range of the 16x16 grid.

```
"grid": {
    "location": "A0:P15"
}
```


### Breaking down the input JSONs

Each example JSON has an include and create field. The include field tells OpenTPG what JSON to load into the system these can be widgets or more include style JSONs.
The create field is an array, where each index is all the widgets to be used per frame. Updates can be added to the widget like so, or the tpig/four.json file can be updated.

```
"four": {"colors" : ["#FF0000", "#00FF00", "#00000F", "#00FF0F", "#FFFFFF"]}
```
This will overwrite the original colors in four with ["#FF0000", "#00FF00", "#00000F", "#00FF0F", "#FFFFFF"]. 


The file labelandfour.json has the create section ordered as ` "create": [{"four": {}},{"label": {}}]` this explicitly tells open tpg to run the four widget before the label widget. This behaves differently from the other create function as it is a nested JSON file and does not effect the frame order.


### Things to try

Try updating the colours to be used by the colouring algorithm with the following JSON. Replace the create field in tpig/labelandfour.json and try running the example `./opentpg --c tpig/tpigexample.json --log stdout --debug` again.

```
"create": [
    {
    "label": {},
    "four": {"colors" :["#FC440F", "#1EFFBC", "#7C9299", "#1F01B9", "#B4E33D"]}
    }
]
```


Or change it so that only half of the test pattern is filled in with four colours. The other half will be a gray background
```
"create": [
    {
    "label": {},
    "four": {"grid": {
        "location": "A0:H15"
    }}
    }
]
```
These can be combined to form a half filled screen with a new colour palette.

```

 "create": [
        {
            "canvas": {},
            "label": {
                "colors": [
                    "#F7F4EA",
                    "#DED9E2",
                    "#C0B9DD",
                    "#80A1D4",
                    "#75C9C8"
                ],
                "grid": {
                    "location": "A0:H15"
                }
            }
        }
    ]
```


## TPIG file layout 

The size of the resulting flat image is declared in `"Dimensions": {"Flat": {}}`. The carve locations and their relative sizes  are declared in  ` "Carve": {"A1": {}}` , this gives the carve name and its size.

TileLayout is an array of the tile's flat position, carve position and the carved location of the tile. This information is used with the geometry of the system and creating a mask of the shape, that is the area of the image that can be filled in. Areas of the main image that do not correlate to a tile will not be coloured in under any circumstance. The tags gives extra information about each tile such as it's neighbours.
