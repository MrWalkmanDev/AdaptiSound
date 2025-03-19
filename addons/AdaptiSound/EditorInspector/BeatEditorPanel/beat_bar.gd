@tool
extends TextureRect

signal key_pressed(value, idx)

@onready var button : TextureButton = $TextureRect

var key_idx : int = 0

var button_pressed : bool = false:
	set(value):
		button_pressed = value
		if button:
			button.button_pressed = button_pressed

func _ready() -> void:
	button.button_pressed = button_pressed

func _on_texture_rect_toggled(toggled_on: bool) -> void:
	key_pressed.emit(toggled_on, key_idx)
