extends EditorInspectorPlugin

const PLAY_PROPERTY = preload("res://addons/AdaptiSound/EditorInspector/InteractivePlayer/PlayProperty.gd")
const STOP_PROPERTY = preload("res://addons/AdaptiSound/EditorInspector/InteractivePlayer/StopProperty.gd")

func _can_handle(object):
	return object is AdaptiNode
	
#func _parse_begin(object):
	### begining inspector
	#pass
	
func _parse_property(object, type, name, hint_type, hint_string, usage_flags, wide):
	#print_info(object, type, name, hint_type, hint_string)
	if name == "_play":
		var play_property = PLAY_PROPERTY.new()
		add_property_editor("_play", play_property)
		return true
	if name == "_stop":
		var stop_property = STOP_PROPERTY.new()
		add_property_editor("_stop", stop_property)
		return true
		

func print_info(object, type, name, hint_type, hint_string):
	print("object: " + str(object))
	print("type: " + str(type))
	print("name: " + str(name))
	print("hint_type: " + str(hint_type))
	print("hint_string: " + str(hint_string))
	print("----------------------------")
	
