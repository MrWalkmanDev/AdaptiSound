extends Node2D

## -------------------------------------------------------------------------------------------------
#############
## TRACK 1 ##
#############

@export var track_1_name : String = "battle"

func _on_play_track_1_pressed():
	var track = AudioManager.create_audio_track(track_1_name)
	if !track.playing:
		set_visual_button(%Play_clip0)
		
	AudioManager.play_music(track_1_name, 0.0, 0.5, 0.5)

func _on_play_clip_0_pressed():
	AudioManager.change_loop(track_1_name, 0)
	set_visual_button(%Play_clip0)

func _on_play_clip_1_pressed():
	AudioManager.change_loop(track_1_name, 1)
	set_visual_button(%Play_clip1)

func _on_play_clip_2_pressed():
	AudioManager.change_loop(track_1_name, 2)
	set_visual_button(%Play_clip2)
	
func _on_play_clip_3_pressed():
	AudioManager.change_loop(track_1_name, 3)
	set_visual_button(%Play_clip3)

func _on_stop_track_1_pressed():
	AudioManager.stop_music(0.5)
	set_visual_button(null)
	
func set_visual_button(node):
	for i in %Track1_container.get_children():
		i.modulate = "#ffffff"
	if node:
		node.modulate = Color.GREEN



## -------------------------------------------------------------------------------------------------
#############
## TRACK 2 ##
#############

func _on_play_track_2_pressed():
	## ParallelTrack ##
	var track = AudioManager.play_music("swing", 0.0, 0.5, 0.5)
	#AudioManager.mute_layer("swing", [0], false, 0.0)

func _on_layer_1_track_2_toggled(toggled_on):
	AudioManager.mute_layer("swing", [0], !toggled_on)


func _on_layer_2_track_2_toggled(toggled_on):
	AudioManager.mute_layer("swing", [1], !toggled_on)


func _on_layer_3_track_2_toggled(toggled_on):
	AudioManager.mute_layer("swing", [2], !toggled_on)
	
func _on_stop_track_2_pressed():
	AudioManager.stop_music(0.5, false)



## -------------------------------------------------------------------------------------------------
#############
## TRACK 3 ##
#############

@export var track_3_name : String = "AdaptiExample"

func _on_play_pressed():
	#var track : AdaptiTrack = AudioManager.create_audio_track(track_name)
	#track.set_first_loop(1).set_skip_intro(true)
	AudioManager.play_music(track_3_name)

func _on_loop_1_pressed():
	AudioManager.change_loop(track_3_name, 0)


func _on_loop_2_pressed():
	AudioManager.change_loop(track_3_name, 1)


func _on_loop_3_pressed():
	AudioManager.change_loop(track_3_name, 2)
	
	
func _on_layer_1_toggled(button_pressed):
	if button_pressed:
		AudioManager.mute_layer(track_3_name, [0], false, 1.5, 2)
	else:
		AudioManager.mute_layer(track_3_name, [0], true, 1.5, 2)


func _on_layer_2_toggled(button_pressed):
	if button_pressed:
		AudioManager.mute_layer(track_3_name, [1], false)
	else:
		AudioManager.mute_layer(track_3_name, [1], true)


func _on_layer_3_toggled(button_pressed):
	if button_pressed:
		AudioManager.mute_layer(track_3_name, [2], false)
	else:
		AudioManager.mute_layer(track_3_name, [2], true)


func _on_outro_pressed():
	AudioManager.to_outro(track_3_name)
	#AudioManager.stop_music(true)
	#AudioManager.stop_all()


func _on_stop_pressed():
	#AudioManager.stop_music(1.0)
	AudioManager.stop_all(1.0)
