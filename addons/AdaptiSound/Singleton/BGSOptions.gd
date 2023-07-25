extends Node

func play_sound(sound_name: String, volume_db := 0.0, fade_in: = 0.5,
	fade_out:= 1.5, skip_intro := false, loop_index := 0):
	
	## Get data of track
	var track_data = AudioManager.get_track_data(sound_name)
	if track_data == null:
		AudioManager.debug._print("DEBUG: Track name not found")
		return
		
	if track_data.type != "BGS":
		AudioManager.debug._print("DEBUG: The track is not BGS")
		return
	
	## Add Track
	var audio_stream = AudioManager.tools.add_track(sound_name, track_data)
	
	if AudioManager.current_bgs_playback == audio_stream:
		AudioManager.debug._print("DEBUG: Track already playing")
		return audio_stream
	
	## Stop Current Track
	if AudioManager.current_bgs_playback != null:
		AudioManager.tools.check_fade(AudioManager.current_bgs_playback, fade_out, false)
	
	## Play New Track
	audio_stream.volume_db = volume_db
	AudioManager.tools.check_fade(audio_stream, fade_in, true, volume_db)
	AudioManager.current_bgs_playback = audio_stream
	
	return audio_stream


func stop_sound(can_fade := false, fade_time := 1.5):
	var track
	if can_fade == false:
		fade_time = 0.0
		
	if AudioManager.current_bgs_playback != null:
		track = AudioManager.current_bgs_playback
		AudioManager.tools.check_fade(AudioManager.current_bgs_playback, fade_time, false)
	
	AudioManager.current_bgs_playback = null ## Problemas con el Fade out
	return track


func mute_bgs_layer(track_name: String, layer_names: Array, mute_state: bool, fade_time := 2.0):
		
	var track = AudioManager.get_audio_track(track_name)
	if track != null and AudioManager.current_bgs_playback == track and track is AdaptiNode:
		track.on_mute_layers(layer_names, mute_state, fade_time, -1)
	else:
		AudioManager.debug._print("DEBUG: ParallelTrack not found")
