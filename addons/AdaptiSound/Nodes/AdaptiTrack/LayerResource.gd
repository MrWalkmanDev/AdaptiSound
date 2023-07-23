extends Resource

class_name LayerResource

## Choose the number of tracks that will be played on this layer
@export var audio_stream : AudioStream

## Assign name to the layer
@export var layer_name : String

## If true, it will not be listening when calling [b]on_play()[/b]
@export var mute = false

## Choose if the layer is a loop
@export var loop = true

@export_group("Groups")
## Assign groups of layer
@export var groups : Array[String]
