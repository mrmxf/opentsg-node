# Generators

These take large sections of data and duplicate / overwrite widgets

to produce voerwrite widgets without writing messy factories.

## how does it work

The generate function runs BEFROE/AFTER create.

It takes a base widget and duplicates it replacing speified fields with
the values from the data.

e.g. the field "colour" is replaced with something like 

## factory layout

## Data layout

The dimension allow ndimensonsl data be placed in an array.
The formula is recursive. the dimensions mean theres 5 lots of 4 lots of 3
and only the fully poluated bits work.

The first 3 are x.y.0 then etc

Dimnesion is a short hand of the layout

its a map of {dimensions data array}
