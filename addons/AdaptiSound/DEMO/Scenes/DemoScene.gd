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
	
	## I create a variable to save the AudioPlayer, since I will use it later.
	var track : AdaptiNode
	
	## Now i check if AudioManager is already playing a previous track, 
	## because if there is no track playing previously I want the new track to start without fading in
	if !AudioManager.current_playback:
		track = AudioManager.play_music(track_1_name, 0.0)
	## And if there is a previous track then I want to apply a crossfade, 
	## assigning the fade_in and fade_out time after the volume parameter.
	else:
		track = AudioManager.play_music(track_1_name, 0.0, 0.7, 1.0)
	## NOTE: The play_music method defaults to 0.0db volume, fade_in 0.0, and fade_out 0.0.
	## Therefore, there is no crossfade if no fade time is assigned.
	
	
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
	## In this line I used the track name instead of the index
	AudioManager.change_clip(track_1_name, "Loop2")
	
func _on_play_clip_3_pressed():
	## I set the can_be_interrupted variable manually to prevent a switch
	## to another clip on the same track.
	## This variable can be changed in the AudioEditroPreview, 
	## but in this case I change it manually as an example
	AudioManager.set_can_be_interrupted(track_1_name, "Outro", false)
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
	## The same methods are always used
	var track : AdaptiNode
	track = AudioManager.play_music(track_2_name, 0.0, 0.7, 1.0)
	
	## Every time this track plays I want it to start with only layer 1 active, 
	## so I'll mute all the other layers and leave only layer 1.
	AudioManager.mute_all_layers(true, 0.0)
	AudioManager.mute_layer("Layer 0", false, 0.7)
	
	## In this case, with this function I update the state of the track layer buttons.
	## It's just a visual aid to know which layer is playing and which isn't.
	layer_buttons_update(track)
	current_playback_label.text = "Current Playback: " + track_2_name


## Buttons to activate the different layers
## You can use the layer index, or the name.
func _on_layer_1_track_2_toggled(toggled_on):
	AudioManager.mute_layer(0, !toggled_on)

func _on_layer_2_track_2_toggled(toggled_on):
	AudioManager.mute_layer(1, !toggled_on)

func _on_layer_3_track_2_toggled(toggled_on):
	AudioManager.mute_layer(2, !toggled_on)
	
## In this case I used the layer name as an example.
func _on_layer_4_track_toggled(toggled_on):
	AudioManager.mute_layer("Layer 3", !toggled_on)

#endregion


#region TRACK_3
## -------------------------------------------------------------------------------------------------
#############
## TRACK 3 ##
#############
var track_3_name : String = "ChillMusic"

## This is the simplest track, I just call the play_music method to play the track.
func _on_play_pressed():
	## In this case it will always start with a crossfade, and set the volume to 2.0db
	AudioManager.play_music(track_3_name, 2.0, 0.7, 1.0)
	
	## Visuals
	current_playback_label.text = "Current Playback: " + track_3_name
#endregion



#region TRACK_4
## -------------------------------------------------------------------------------------------------
#############
## TRACK 4 ##
#############
## This track is an AudioInteractivePlaylist, but with the shuffle option enabled.

var track_4_name : String = "Sequence"

func _on_track_4_play_pressed() -> void:
	var track = AudioManager.play_music(track_4_name, 0.0, 0.7, 1.0)
	
	
	## I connect the signal to the clip changed to better visualize which track is playing
	if !track.ClipChanged.is_connected(track_4_clip_changed):
		track.ClipChanged.connect(track_4_clip_changed)
		track_4_clip_changed(track.current_playback_resource)
#endregion



func _on_bgm_stop_pressed() -> void:
	AudioManager.stop_music(0.5)


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
		
func set_visual_button(node, container:=%Track1):
	for i in container.get_children():
		i.modulate = "#ffffff"
	if node:
		node.modulate = Color.GREEN
		
func layer_buttons_update(track:AdaptiNode):
	var audio_players = track.get_children()
	%Layer1_track2.button_pressed = !audio_players[0].on_mute
	%Layer2_track2.button_pressed = !audio_players[1].on_mute
	%Layer3_track2.button_pressed = !audio_players[2].on_mute
	%Layer4_track2.button_pressed = !audio_players[3].on_mute

func track_4_clip_changed(clip_res:AdaptiClipResource):
	if clip_res:
		if clip_res.clip_name == "Clip1":
			set_visual_button(%Label1, %Track4Clips)
		elif clip_res.clip_name == "Clip2":
			set_visual_button(%Label2, %Track4Clips)
		elif clip_res.clip_name == "Clip3":
			set_visual_button(%Label3, %Track4Clips)
		elif clip_res.clip_name == "Clip4":
			set_visual_button(%Label4, %Track4Clips)


## ------------------------------------------------------------------------------------------------
## BGS Channel ##
func _on_forest_pressed() -> void:
	AudioManager.play_sound("Forest", -3.0)

func _on_rain_pressed() -> void:
	AudioManager.play_sound("Rain", -3.0)

func _on_wind_pressed() -> void:
	AudioManager.play_sound("Wind", 3.0)

func _on_bgs_stop_pressed() -> void:
	AudioManager.stop_sound(2.0)
