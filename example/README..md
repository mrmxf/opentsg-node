# Generators

Generators are used for making large volumes of widgets. Either
for single frames with lots of widgets or lots of frames with single widgets.
With a main aim of reducing the number of widgets being declared in factories.

## how does it work

The generate field always runs before the create field, in every factory json.
They do **not** take precedence over create fields in parent factories.

Generate works by taking a base widget and using it to generate a new widget, 
replacing specified
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
           "d.{{swatchTypes}}": ["grid.location","backgroundColor"]}
          }
      }
    ]
  }
```

### Data and base widget

The include section contains a base widget `pyramid` and
a data json `d`. You can include additional widgets to
run in the create section, the factory can use both
the generate and create fields in the same instance
without any repercussions.

```json
"include": [
      { "uri": "pyramid.json", "name": "pyramid" },
      { "uri": "pyramid-data.json", "name": "d" }
    ]
```

### Generate Section

The name field is the naming format of the dot paths that are generated with the widgets, as well as declaring
the range of the values to choose from the data. The length of the name array has to match the number of dimensions,
as each position in the array matches a dimension of the data.
e.g. the first position in the array relates to the first dimension of the data, so `{"R":"[:]"}` would name the
first dimension of the data `R{{number}}`.
In this demo `[:]` means use the full range of that data dimension. `[0:2]` would be an inclusive:exclusive range of the data.
The key is the name that is used to generate that name at layer of the dotpath, which is followed by the dimension position.
In this demo the names would go from R0.CD0.B0
to R4.CD3.B2. Where the full name is `"frame.swatch.blueR0.CD1.B0"`

```json
"name": [{"R":"[:]"}, {"CD":"[:]"}, {"B":"[:]"}],
```

The action below says for the widget pyramid, use the data `d` with the field {{swatchTypes}},
the data name is whatever was declared in the include section.
Then update these fields "grid.location","backgroundColor" from the base widget with the values from data
in the generated widget.

```json
 "action": {
           "pyramid" : {
           "d.{{swatchTypes}}": ["grid.location","backgroundColor"]}
          }
```

## factory layout

## Data layout

The dimension allow ndimensons of to data be placed in a single dimension array.
The dimensions in the demo mean theres a 3 dimensional dot path, which consists of
5 in the base dimension, eah one of these has 4 further children and those 4 children have a further 3 each.
This results in 60 data points in total. These are stored in a depth first order in the data.

In the demo the range of values with the declared names are R[0:4].CD[0:3].B[0:2]

Dimension gives a simple layout of the data, allowing opentsg to
understand the dimensions of the data.
