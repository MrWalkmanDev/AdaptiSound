extends Node2D

@onready var console = get_node("CanvasLayer/Control/CenterContainer/VBoxContainer/Panel/Console")

var track_name = "JazzTheme"

func _on_play_pressed():
	AudioManager.play_music(track_name)


func _on_layer_1_toggled(button_pressed):
	if button_pressed:
		AudioManager.mute_layer(track_name, ["Base"], false)
	else:
		AudioManager.mute_layer(track_name, [0], true)


func _on_layer_2_toggled(button_pressed):
	if button_pressed:
		AudioManager.mute_layer(track_name, ["Organ"], false)
	else:
		AudioManager.mute_layer(track_name, [1], true)


func _on_layer_3_toggled(button_pressed):
	if button_pressed:
		AudioManager.mute_layer(track_name, ["Melody"], false)
	else:
		AudioManager.mute_layer(track_name, [2], true)

func _on_check_button_toggled(button_pressed):
	if button_pressed:
		AudioManager.mute_layer(track_name, [], false)
	else:
		AudioManager.mute_layer(track_name, [], true)


func _on_stop_pressed():
	AudioManager.stop_music(true)



func _on_trigger_pressed():
	AudioManager.play_layer(track_name, ["Trigger"])
