extends EditorProperty

const _icon = preload("res://addons/AdaptiSound/Icons/Others/play.png")

var property_control = Button.new()

## CLIPS Array Size ##
var current_value : bool = false

## A guard against internal changes when the property is updated.
var updating = false


func _init():
	property_control.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	property_control.icon = _icon
	#property_control.modulate = Color.GREEN
	#set_bottom_editor(property_control)
	property_control.size_flags_horizontal = SIZE_EXPAND_FILL
	# Add the control as a direct child of EditorProperty node.
	add_child(property_control)
	# Make sure the control is able to retain the focus.
	add_focusable(property_control)
	
	## SIGNALS ##
	property_control.connect("pressed", _on_play_button_pressed)


func _on_play_button_pressed():
	# Ignore the signal if the property is currently being updated.
	if (updating):
		return
		
	current_value = true
	emit_changed(get_edited_property(), current_value)

func _update_property():
	# Read the current value from the property.
	var new_value = get_edited_object()[get_edited_property()]
	if (new_value == current_value):
		return
	# Update the control with the new value.
	updating = true
	current_value = new_value
	updating = false
