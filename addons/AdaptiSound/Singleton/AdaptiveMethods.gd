extends Node


######################################
## Combined and Interactive Methods ##
######################################

## Change between loops or clips audios ##
func change_clip(sound_name:String, clip_by_name_or_index, fade_in:float, fade_out:float):
	var audio_stream = AudioManager.get_audio_track(sound_name)
	if audio_stream is AudioInteractivePlayer:
		if audio_stream != null and AudioManager.current_playback == audio_stream:
			audio_stream.on_change_clip(clip_by_name_or_index, fade_in, fade_out)
		else:
			AudioManager.debug._print("DEBUG: Track not found")
	else:
		AudioManager.debug._print("AudioManager: " + sound_name + \
		" Can't use change_clip function because is not an AudioInteractivePlaylist Node.")
	
	
##########################
## Synchronized Methods ##
##########################

## Mute or Unmute diferent layers for BGM Synchronized tracks.
func mute_layer(track, layer, mute_state : bool, fade_time := 2.0):
	if track:
		if track is AudioSynchronizedPlayer:
			track.on_mute_layers(layer, mute_state, fade_time)
		else:
			AudioManager.debug._print("AudioManager: " + track.name + \
			" Can't use mute_layer function because is not an AudioSynchronized Node.")
	else:
		AudioManager.debug._print("AudioManager: Track not found")

## Mute or Unmute all layers for BGM Synchronized tracks.
func mute_all_layers(track, mute_state : bool, fade_time := 2.0):
	if track:
		if track is AudioSynchronizedPlayer:
			track.mute_all_layers(mute_state, fade_time)
		else:
			AudioManager.debug._print("AudioManager: " + track.name + \
			" Can't use mute_all_layers function because is not an AudioSynchronized Node.")
	else:
		AudioManager.debug._print("AudioManager: Track not found")
