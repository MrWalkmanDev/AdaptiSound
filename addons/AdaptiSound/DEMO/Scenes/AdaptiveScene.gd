extends Node2D

var track_name : String = "AdaptiExample"

func _on_play_pressed():
	#var track : AdaptiTrack = AudioManager.create_audio_track(track_name)
	#track.set_first_loop(1).set_skip_intro(true)
	AudioManager.play_music(track_name)

func _on_loop_1_pressed():
	AudioManager.change_loop(track_name, 0)


func _on_loop_2_pressed():
	AudioManager.change_loop(track_name, 1)


func _on_loop_3_pressed():
	AudioManager.change_loop(track_name, 2)
	
	
func _on_layer_1_toggled(button_pressed):
	if button_pressed:
		AudioManager.mute_layer(track_name, [0], false, 1.5, 2)
	else:
		AudioManager.mute_layer(track_name, [0], true, 1.5, 2)


func _on_layer_2_toggled(button_pressed):
	if button_pressed:
		AudioManager.mute_layer(track_name, [1], false)
	else:
		AudioManager.mute_layer(track_name, [1], true)


func _on_layer_3_toggled(button_pressed):
	if button_pressed:
		AudioManager.mute_layer(track_name, [2], false)
	else:
		AudioManager.mute_layer(track_name, [2], true)


func _on_outro_pressed():
	AudioManager.to_outro(track_name)
	#AudioManager.stop_music(true)
	#AudioManager.stop_all()


func _on_stop_pressed():
	#AudioManager.stop_music(1.0)
	AudioManager.stop_all(1.0)


## -------------------------------------------------------------------------------------------------
#############
## TRACK 2 ##
#############

func _on_play_track_2_pressed():
	## ParallelTrack ##
	AudioManager.play_music("AdaptiParallel")
	AudioManager.mute_layer("AdaptiParallel", [0], false)
