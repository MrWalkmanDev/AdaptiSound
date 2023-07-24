@tool
extends Resource

class_name LoopResource

@export_group("Music Layers")
## Set layers in your Loop.
@export var layers : Array[LayerResource] : set = set_custom_res, get = get_custom_res

@export_group("Sequence Track")
## Defines if the loop is a random sequence.
## [br]If true, sequence track plays only one layer at a time, and when finished goes to the next random layer.
## [br][b]Remember set (loop = false) in Layers[/b]
@export var random_sequence : bool = false
## Assign the first audio to be played. [br]If -1, the first play will be random.
@export var first_playback_idx : int = -1
var first_sequence = true

@export_group("Measure Count System")
## Beat per Minutes.
@export var bpm := 120.0
## Number of beats in a measure/bar
@export var metric := 4
## Total beats of the track, this variable is needed for [b]beat count system[/b].
@export var total_beat_count : int

## Points where the loop can transition to another Loop. Use Measure Count
## [br][b]Write the bar numbers separated by a "," without spaces. (1,2,3,4)[/b]
@export var keys_loop_in_measure : String

## Points where the loop can transition to Outro. Use Measure Count
## [br][b]Write the bar numbers separated by a "," without spaces. (1,2,3,4)[/b]
@export var keys_end_in_measure : String


## EDITOR ##

func set_custom_res(value):
	layers.resize(value.size())
	layers = value
	for i in layers.size():
		if not layers[i]:
			layers[i] = LayerResource.new()
			layers[i].resource_name = "LayerRes"
	
func get_custom_res():
	return layers
