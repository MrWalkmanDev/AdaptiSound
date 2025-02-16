extends Node


######################################
## Combined and Interactive Methods ##
######################################

## Change between loops or clips audios ##
func change_loop(sound_name, loop_by_index, fade_in := 0.7, fade_out := 1.0):
	var audio_stream = AudioManager.get_audio_track(sound_name)
	if audio_stream != null and AudioManager.current_playback == audio_stream:
		audio_stream.on_change_loop(loop_by_index, fade_in, fade_out)
	else:
		AudioManager.debug._print("DEBUG: Track not found")

## Change from the Loop section to Outro section
func to_outro(sound_name : String, fade_in := 0.7, fade_out := 1.0):
	var audio_stream = AudioManager.get_audio_track(sound_name)
	if audio_stream != null and AudioManager.current_playback == audio_stream:
		audio_stream.on_outro(fade_out, fade_in)
	else:
		AudioManager.debug._print("DEBUG: Track not found")
		
	return audio_stream
	
	
	
##########################
## Synchronized Methods ##
##########################

## Mute or Unmute diferent layers for BGM Synchronized tracks.
func mute_layer(track_name: String, layer, 
	mute_state : bool, fade_time := 2.0, loop_target := -1):
		
	var track = AudioManager.get_audio_track(track_name)
	if track != null and AudioManager.current_playback == track and track is AdaptiNode:
		track.on_mute_layers(layer, mute_state, fade_time, loop_target)
	else:
		AudioManager.debug._print("DEBUG: " + track_name + " not found")


## Mute or Unmute all layers for BGM Synchronized tracks.
func mute_all_layers(track_name: String, mute_state : bool, fade_time := 2.0, loop_target := -1):
	var track = AudioManager.get_audio_track(track_name)
	if track != null and AudioManager.current_playback == track and track is AdaptiNode:
		track.mute_all_layers(mute_state, fade_time, loop_target)
	else:
		AudioManager.debug._print("DEBUG: " + track_name + " not found")
