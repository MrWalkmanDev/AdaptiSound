@tool
extends CheckBox

signal key_pressed(value, idx)

var key_idx : int = 0


func _on_toggled(toggled_on: bool) -> void:
	key_pressed.emit(toggled_on, key_idx)
