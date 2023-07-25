extends CanvasLayer

var track_name = "ABGSTrack"

func _on_button_pressed():
	AudioManager.play_sound(track_name)

func _on_layer_1_toggled(button_pressed):
	AudioManager.mute_bgs_layer(track_name, [0], !button_pressed)

func _on_layer_2_toggled(button_pressed):
	AudioManager.mute_bgs_layer(track_name, [1], !button_pressed)

func _on_layer_3_toggled(button_pressed):
	AudioManager.mute_bgs_layer(track_name, [2], !button_pressed)

func _on_stop_pressed():
	AudioManager.stop_sound(true)
