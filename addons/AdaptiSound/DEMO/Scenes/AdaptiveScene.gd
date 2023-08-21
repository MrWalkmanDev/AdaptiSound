extends Node2D

func _on_play_pressed():
	AudioManager.play_music("AdaptiExample", 0.0)


func _on_loop_1_pressed():
	AudioManager.change_loop("AdaptiExample", 0)


func _on_loop_2_pressed():
	AudioManager.change_loop("AdaptiExample", 1)


func _on_loop_3_pressed():
	AudioManager.change_loop("AdaptiExample", 2)
	
	
func _on_layer_1_toggled(button_pressed):
	if button_pressed:
		AudioManager.mute_layer("AdaptiExample", [0], false, 1.5, 2)
	else:
		AudioManager.mute_layer("AdaptiExample", [0], true, 1.5, 2)


func _on_layer_2_toggled(button_pressed):
	if button_pressed:
		AudioManager.mute_layer("AdaptiExample", [1], false)
	else:
		AudioManager.mute_layer("AdaptiExample", [1], true)


func _on_layer_3_toggled(button_pressed):
	if button_pressed:
		AudioManager.mute_layer("AdaptiExample", [2], false)
	else:
		AudioManager.mute_layer("AdaptiExample", [2], true)


func _on_outro_pressed():
	AudioManager.to_outro("AdaptiExample")
	#AudioManager.stop_music(true)
	#AudioManager.stop_all()
