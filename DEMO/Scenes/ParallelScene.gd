extends Node2D

@onready var console = get_node("CanvasLayer/Control/CenterContainer/VBoxContainer/Panel/Console")


func _on_play_pressed():
	AudioManager.play_music("")
	console.text = "AudioManager.play_music()"


func _on_layer_1_toggled(button_pressed):
	if button_pressed:
		AudioManager.layer_on("", [0])
		console.text = "AudioManager.layer_on()"
	else:
		AudioManager.layer_off("", [0])
		console.text = "AudioManager.layer_off()"


func _on_layer_2_toggled(button_pressed):
	if button_pressed:
		AudioManager.layer_on("", [1])
		console.text = "AudioManager.layer_on()"
	else:
		AudioManager.layer_off("", [1])
		console.text = "AudioManager.layer_off()"


func _on_layer_3_toggled(button_pressed):
	if button_pressed:
		AudioManager.layer_on("", [2])
		console.text = "AudioManager.layer_on()"
	else:
		AudioManager.layer_off("", [2])
		console.text = "AudioManager.layer_off()"

func _on_check_button_toggled(button_pressed):
	if button_pressed:
		AudioManager.layer_on("", [])
		console.text = "AudioManager.layer_on()"
	else:
		AudioManager.layer_off("", [])
		console.text = "AudioManager.layer_off()"


func _on_stop_pressed():
	AudioManager.stop_music()
	console.text = "AudioManager.stop_music()"


