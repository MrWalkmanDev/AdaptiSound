extends Node2D

@onready var console = get_node("CanvasLayer/Control/CenterContainer/VBoxContainer/Panel/Console")


func _on_play_pressed():
	AudioManager.play_music("JazzTheme")
	console.text = "AudioManager.play_music()"


func _on_layer_1_toggled(button_pressed):
	if button_pressed:
		AudioManager.layer_on("JazzTheme", [0])
		console.text = "AudioManager.layer_on(sound_name, [0])"
	else:
		AudioManager.layer_off("JazzTheme", [0])
		console.text = "AudioManager.layer_off(sound_name, [0])"


func _on_layer_2_toggled(button_pressed):
	if button_pressed:
		AudioManager.layer_on("JazzTheme", [1])
		console.text = "AudioManager.layer_on(sound_name, [1])"
	else:
		AudioManager.layer_off("JazzTheme", [1])
		console.text = "AudioManager.layer_off(sound_name, [1])"


func _on_layer_3_toggled(button_pressed):
	if button_pressed:
		AudioManager.layer_on("JazzTheme", [2])
		console.text = "AudioManager.layer_on(sound_name, [2])"
	else:
		AudioManager.layer_off("JazzTheme", [2])
		console.text = "AudioManager.layer_off(sound_name, [2])"

func _on_check_button_toggled(button_pressed):
	if button_pressed:
		AudioManager.layer_on("JazzTheme", [])
		console.text = "AudioManager.layer_on(sound_name, [])"
	else:
		AudioManager.layer_off("JazzTheme", [])
		console.text = "AudioManager.layer_off(sound_name, [])"


func _on_stop_pressed():
	AudioManager.stop_music(true)
	console.text = "AudioManager.stop_music(true)"


