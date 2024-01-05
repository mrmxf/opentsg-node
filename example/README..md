# Generators

Generators are used for making large volumes of widgets. Either
for single frames with lots of widgets or lots of frames with single widgets.

these are for reducing the numebr of widgtes being declared in factories.

## how does it work

The generate section before the create field.

It takes a base widget and duplicates it as a new dotpath, replacing specified
fields in the base widget with the values from the data.

```json
{
    "documentation": [
      "## Swatch widget",
      "",
      "Render a matrix of pyramid squares over a background (possibly",
      "",
      "`swatchParams` property is set by parent"
    ],
    "include": [
      { "uri": "pyramid.json", "name": "pyramid" },
      { "uri": "pyramid-data.json", "name": "d" }
    ],
    "generate": [
      {
          "name": [{"R":"[:]"}, {"CD":"[:]"}, {"B":"[:]"}],
          "action": {
           "pyramid" : {
           "d.{{swatchParams}}": ["grid.location","backgroundcolor"]}
          }
      }
    ]
  }
```

### Data and base widget

the include section contains a base widget `pyramid` and
a data json `d`

```json
"include": [
      { "uri": "pyramid.json", "name": "pyramid" },
      { "uri": "pyramid-data.json", "name": "d" }
    ]
```

### Generate
the generate  data section

name is the format of the dotpaths as well as the range of the values to choose.
In this demo `[:]` means use it all. And the key is the name that is filled in with the dot path
the names are created as so. KEY{metadatadimension} so in this one it would go from R0.CD0.B0
to R4.CD3.B2.

The action says for pyramid
extract from the data the green data points and update these fields "grid.location","backgroundcolor"
in the duplicated widget

## factory layout

## Data layout

The dimension allow ndimensonsl data be placed in an array.
The formula is recursive. the dimensions mean theres 5 lots of 4 lots of 3
and only the fully poluated bits work.

The first 3 are x.y.0 then etc

The data is a flat row by row lay out, starting at 0.

Dimnesion is a short hand of the layout, allowing opentsg to
understand the dimnesions of the data. for when more than one dimension is used.
For no dimensions present (NOT IMPLEMENTED) then its taken to be flat

its a map of {dimensions data array}
