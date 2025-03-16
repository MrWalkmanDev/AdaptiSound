@tool
extends Resource
class_name AdaptiClipResource

signal clip_resource_changed(clip, res)
signal auto_advance_changed(value, res)
#signal clip_name_changed(text, res)

## Name of the clip which can be called later for playback.
@export var clip_name : StringName #: set = set_clip_name
## Audio file to be played. [br]
## [b]WAV files must be imported with the loop option set previously for the system to work.[/b]
@export var clip : AudioStream : set = set_clip
## Choose how the clip advances once it has finished[br]
## [b]Loop[/b] repeats the same clip infinitely after finishing.[br]
## [b]Auto-advance[/b] will play the selected clip in a queue after finishing.[br]
## [b]Once[/b] plays once and stops playing.[br]
## [b]WAV files must be imported with the loop option set previously for the system to work.[/b]
@export_enum("Loop", "Auto-advance", "Once") var advance_type : int = 0 : set = set_loop

## Will play the selected clip in a queue after finishing.
var _next_clip : String:
	get:
		return _next_clip
	set(value):
		_next_clip = value

var total_clips : Array[AdaptiClipResource]:
	get:
		return total_clips
	set(value):
		total_clips = value
		notify_property_list_changed()
		
@export var bpm : int = 120
@export var beats_per_bar : int = 4
@export var key_bars : Array[int] = []
		
func _validate_property(property):
	if property.name == "_next_clip" and advance_type != 1:
		property.usage = PROPERTY_USAGE_NO_EDITOR
		

func _get_property_list():
	var properties = []
	
	properties.append({
		"name" : "_next_clip",
		"type" : TYPE_STRING,
		"hint" : PROPERTY_HINT_ENUM,
		"hint_string" : _array_to_string(total_clips)
	})
	return properties
	
func _array_to_string(arr:Array[AdaptiClipResource], separator:=",") -> String:
	var string = ""
	for i in arr:
		string += i.clip_name + separator
	return string

#func set_clip_name(value:String):
	#clip_name = value
	#clip_name_changed.emit(clip_name, self)

func set_clip(resource):
	clip = resource
	clip_resource_changed.emit(clip, self)
	
func set_loop(value):
	advance_type = value
	auto_advance_changed.emit(value, self)
	notify_property_list_changed()
