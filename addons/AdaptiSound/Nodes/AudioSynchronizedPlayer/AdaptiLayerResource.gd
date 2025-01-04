@tool
extends Resource
class_name AdaptiLayerResource


signal layer_resource_changed(layer, res)
signal mute_layer_changed(mute, res)
#signal clip_name_changed(text, res)

## Name of the audio layer.
@export var layer_name : StringName #: set = set_clip_name
## Audio file to be played. [br]
## [b]Remember to import this file with the loop option enabled[/b]
@export var clip : AudioStream : set = set_clip
#@export_range(-80.0, 24.0) var volume_db : float = 0.0 : set = set_volume_db
## If true, the layer will play silently.
## Use this variable in the editor to set which layers should start muted or not.[br]
## In the editor preview you can run this parameter to see the changes.
@export var mute : bool = false :set = set_mute



#func _validate_property(property):
	#if property.name == "_next_clip" and advance_type != 1:
		#property.usage = PROPERTY_USAGE_NO_EDITOR
		

#func _get_property_list():
	#var properties = []
	#
	#properties.append({
		#"name" : "_next_clip",
		#"type" : TYPE_STRING,
		#"hint" : PROPERTY_HINT_ENUM,
		#"hint_string" : _array_to_string(total_clips)
	#})
	#return properties

#func set_clip_name(value:String):
	#clip_name = value
	#clip_name_changed.emit(clip_name, self)
	
func set_mute(value):
	mute = value
	mute_layer_changed.emit(value, self)
	
#func set_volume_db(value):
#	volume_db = value

func set_clip(resource):
	clip = resource
	layer_resource_changed.emit(clip, self)
