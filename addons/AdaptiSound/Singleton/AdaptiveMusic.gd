extends Node


######################
## Playback Options ##
######################

func change_loop(sound_name, loop_by_index, can_fade := false,
	fade_in := 0.5, fade_out := 1.5):
	if can_fade == false:
		fade_in = 0.0
		fade_out = 0.0
	
	var audio_stream = AudioManager.get_audio_track(sound_name)
	if audio_stream != null:
		audio_stream.change_loop(loop_by_index, fade_in, fade_out)
	else:
		AudioManager.debug._print("DEBUG: Track not found")


func to_outro(sound_name : String, can_fade := false, fade_out := 1.5, fade_in := 0.5,):
	if can_fade == false:
		fade_in = 0.0
		fade_out = 0.0
		
	var audio_stream = AudioManager.get_audio_track(sound_name)
	if audio_stream != null:
		audio_stream.on_outro(fade_out, fade_in)
	else:
		AudioManager.debug._print("DEBUG: Track not found")
		
	return audio_stream
	
	
	
	###################
	## ParallelTrack ##
	###################
	
func layer_on(track_name: String, layer_names: Array, fade_time := 2.0):
	var track = AudioManager.get_audio_track(track_name)
	if track != null and AudioManager.current_playback == track:
		track.on_layers(layer_names, fade_time)
	else:
		AudioManager.debug._print("DEBUG: ParallelTrack not found")


func layer_off(track_name: String, layer_names: Array, fade_time := 3.0):
	var track = AudioManager.get_audio_track(track_name)
	if track != null and AudioManager.current_playback == track:
		track.off_layers(layer_names, fade_time)
	else:
		AudioManager.debug._print("DEBUG: ParallelTrack not found")


func play_layer(track_name: String, layer_names: Array, can_fade := false, fade_time := 3.0):
	if can_fade == false:
		fade_time = 0.0
	var track = AudioManager.get_audio_track(track_name)
	if track != null and AudioManager.current_playback == track:
		track.play_layer(layer_names, fade_time)
	else:
		AudioManager.debug._print("DEBUG: ParallelTrack not found")


func stop_layer(track_name: String, layer_names: Array, can_fade := false, fade_time := 3.0):
	if can_fade == false:
		fade_time = 0.0
	var track = AudioManager.get_audio_track(track_name)
	if track != null and AudioManager.current_playback == track:
		track.stop_layer(layer_names, fade_time)
	else:
		AudioManager.debug._print("DEBUG: ParallelTrack not found")
