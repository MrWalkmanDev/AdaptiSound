extends Node2D

@onready var console = get_node("CanvasLayer/Control/CenterContainer/VBoxContainer/Panel/Console")

func _on_play_pressed():
	AudioManager.play_music("JazzTheme")
	console.text = "AudioManager.play_music()"


func _on_layer_1_toggled(button_pressed):
	if button_pressed:
		AudioManager.mute_layer("JazzTheme", [0], false, 1.5)
		console.text = "AudioManager.layer_on(sound_name, [0])"
	else:
		AudioManager.mute_layer("JazzTheme", [0], true)
		console.text = "AudioManager.layer_off(sound_name, [0])"


func _on_layer_2_toggled(button_pressed):
	if button_pressed:
		AudioManager.mute_layer("JazzTheme", [1], false)
		console.text = "AudioManager.layer_on(sound_name, [1])"
	else:
		AudioManager.mute_layer("JazzTheme", [1], true)
		console.text = "AudioManager.layer_off(sound_name, [1])"


func _on_layer_3_toggled(button_pressed):
	if button_pressed:
		AudioManager.mute_layer("JazzTheme", [2], false)
		console.text = "AudioManager.layer_on(sound_name, [2])"
	else:
		AudioManager.mute_layer("JazzTheme", [2], true)
		console.text = "AudioManager.layer_off(sound_name, [2])"

func _on_check_button_toggled(button_pressed):
	if button_pressed:
		AudioManager.mute_layer("JazzTheme", [], false)
		console.text = "AudioManager.layer_on(sound_name, [])"
	else:
		AudioManager.mute_layer("JazzTheme", [], true)
		console.text = "AudioManager.layer_off(sound_name, [])"


func _on_stop_pressed():
	AudioManager.stop_music(true)
	console.text = "AudioManager.stop_music(true)"




func _on_trigger_pressed():
	AudioManager.play_layer("JazzTheme", ["Trigger"])
