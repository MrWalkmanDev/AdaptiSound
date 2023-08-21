extends Node2D

@onready var console = get_node("CanvasLayer/Control/CenterContainer/VBoxContainer/Panel/Console")

var track_name = "JazzTheme"

func _on_play_pressed():
	AudioManager.play_music(track_name)

func _on_layer_1_toggled(button_pressed):
	AudioManager.mute_layer(track_name, ["Base"], !button_pressed)

func _on_layer_2_toggled(button_pressed):
	AudioManager.mute_layer(track_name, ["Organ"], !button_pressed)

func _on_layer_3_toggled(button_pressed):
	AudioManager.mute_layer(track_name, ["Melody"], !button_pressed)

func _on_check_button_toggled(button_pressed):
	AudioManager.mute_layer(track_name, [], !button_pressed)

func _on_stop_pressed():
	AudioManager.stop_music(true)


func _on_trigger_pressed():
	AudioManager.play_layer(track_name, ["Trigger"])
