extends Node2D

@onready var current_playback_label = %CurrentPlayback


#region TRACK_1
## -------------------------------------------------------------------------------------------------
#############
## TRACK 1 ##
#############

var track_1_name : String = "example_1"

## AudioInteractivePlayList Methods
## This button plays the track from the beginning
func _on_play_track_1_pressed():
	## I execute the play function from the AudioManager, passing the track_name,
	## volume_db, fade_in and fade_out. The track name is the one assigned in the Audio Panel,
	## The fade_out parameter is applied to the track before the new one, 
	## this way you can create a cross fade effect using fade_in and fade_out parameters.
	var track = AudioManager.play_music(track_1_name, 0.0, 0.5, 0.5)
	
	## Get resource of currently playing clip.
	## In this case, I use the clip change signal to change the color of the  
	## buttons when changing clips.
	if !track.ClipChanged.is_connected(clip_changed):
		track.ClipChanged.connect(clip_changed)
		clip_changed(track.current_playback_resource)
		
	current_playback_label.text = "Current Playback: " + track_1_name

## Buttons to change the clip to play
func _on_play_clip_0_pressed():
	## To change a clip you need to name the track it belongs to, and the clip index. 
	## (It can also be the name given in the clip resource)
	AudioManager.change_clip(track_1_name, 0)

func _on_play_clip_1_pressed():
	AudioManager.change_clip(track_1_name, 1)

func _on_play_clip_2_pressed():
	AudioManager.change_clip(track_1_name, 2)
	
func _on_play_clip_3_pressed():
	AudioManager.change_clip(track_1_name, 3)
#endregion


#region TRACK_2
## -------------------------------------------------------------------------------------------------
#############
## TRACK 2 ##
#############

var track_2_name : String = "example_3"

## AudioSynchronized Methods
## This button plays the track from the beginning
func _on_play_track_2_pressed():
	## I use the same method as track 1.
	var track = AudioManager.play_music(track_2_name, 0.0, 0.5, 0.5)
	
	## In this case, with this function I update the state of the track layer buttons.
	## It's just a visual aid to know which layer is playing and which isn't.
	layer_buttons_update(track)
	current_playback_label.text = "Current Playback: " + track_2_name


## Buttons to activate the different layers
## You can use the layer index, or the name.
func _on_layer_1_track_2_toggled(toggled_on):
	AudioManager.mute_layer(track_2_name, 0, !toggled_on)

func _on_layer_2_track_2_toggled(toggled_on):
	AudioManager.mute_layer(track_2_name, 1, !toggled_on)

func _on_layer_3_track_2_toggled(toggled_on):
	AudioManager.mute_layer(track_2_name, 2, !toggled_on)
	
## In this case I used the layer name as an example.
func _on_layer_4_track_toggled(toggled_on):
	AudioManager.mute_layer(track_2_name, "Layer 3", !toggled_on)

#endregion


#region TRACK_3
## -------------------------------------------------------------------------------------------------
#############
## TRACK 3 ##
#############

var track_3_name : String = "AdaptiExample"

func _on_play_pressed():
	AudioManager.play_music(track_3_name)
	
	current_playback_label.text = "Current Playback: " + track_3_name

func _on_loop_1_pressed():
	AudioManager.change_loop(track_3_name, 0)


func _on_loop_2_pressed():
	AudioManager.change_loop(track_3_name, 1)


func _on_loop_3_pressed():
	AudioManager.change_loop(track_3_name, 2)
	
	
func _on_layer_1_toggled(button_pressed):
	if button_pressed:
		AudioManager.mute_layer(track_3_name, 0, false, 1.5, 2)
	else:
		AudioManager.mute_layer(track_3_name, 0, true, 1.5, 2)


func _on_layer_2_toggled(button_pressed):
	if button_pressed:
		AudioManager.mute_layer(track_3_name, 1, false)
	else:
		AudioManager.mute_layer(track_3_name, 1, true)


func _on_layer_3_toggled(button_pressed):
	if button_pressed:
		AudioManager.mute_layer(track_3_name, 2, false)
	else:
		AudioManager.mute_layer(track_3_name, 2, true)


func _on_outro_pressed():
	AudioManager.to_outro(track_3_name)

#endregion



## -----------------------------------------------------------------------------------------------
## Stop all tracks. In this case with a fade out of 0.5 sec.
func _on_stop_track_1_pressed():
	AudioManager.stop_all(0.5)
	set_visual_button(null)
	
	
	
	
## -----------------------------------------------------------------------------------------------
## BUTTONS VISUALS ##
func clip_changed(clip_res:AdaptiClipResource):
	if clip_res:
		if clip_res.clip_name == "Intro":
			set_visual_button(%Play_clip0)
		elif clip_res.clip_name == "Loop1":
			set_visual_button(%Play_clip1)
		elif clip_res.clip_name == "Loop2":
			set_visual_button(%Play_clip2)
		elif clip_res.clip_name == "Outro":
			set_visual_button(%Play_clip3)
		
func set_visual_button(node):
	for i in %Track1.get_children():
		i.modulate = "#ffffff"
	if node:
		node.modulate = Color.GREEN
		
func layer_buttons_update(track:AdaptiNode):
	var audio_players = track.get_children()
	%Layer1_track2.button_pressed = !audio_players[0].on_mute
	%Layer2_track2.button_pressed = !audio_players[1].on_mute
	%Layer3_track2.button_pressed = !audio_players[2].on_mute
	%Layer4_track2.button_pressed = !audio_players[3].on_mute
