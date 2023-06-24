extends Node

#class_name AdaptiveMusic

######################
## Playback Options ##
######################

var current_playback : Node

func play_music(sound_name : String, fade_time := 0.0, skip_intro := false, loop_index := 0):
	var audio_stream = add_adaptive_track(sound_name)
	if audio_stream != null:
		var audio_on_playing = audio_stream.get_stream_playing()
		if audio_on_playing == null:
			if skip_intro:
				audio_stream.on_play_loop(fade_time, loop_index)
			else:
				audio_stream.on_play(fade_time, skip_intro, loop_index)
				
			current_playback = audio_stream
			
	return audio_stream
		
func change_loop(sound_name, loop_by_index, can_fade := false,
	fade_in := 0.5, fade_out := 1.5):
	if can_fade == false:
		fade_in = 0.0
		fade_out = 0.0
	
	var audio_stream = AudioManager.get_audio_track(sound_name, "abgm")
	if audio_stream != null:
		audio_stream.change_loop(loop_by_index, fade_in, fade_out)
	else:
		AudioManager.debug._print("DEBUG: Track not found")
		
func change_track(from_track, to_track : String, fade_out := 1.5, fade_in := 0.5, 
	skip_intro := false, loop_index := 0, can_destroy := false):
	var audio_stream = add_adaptive_track(to_track)
	var audio_on_playing = audio_stream.get_stream_playing()
	
	## Only can change when current track stopped 
	if audio_on_playing != null:
		AudioManager.debug._print("DEBUG: Track already playing")
		return
	
	## Verify current track
	var current_track
	if from_track == null:
		current_track = current_playback
	else:
		current_track = AudioManager.get_audio_track(from_track, "abgm")
	
	#if current_track.current_playback == current_track.intro_player:
	#	AudioManager.debug._print("DEBUG: Can change in intro")
	#	return
	
	## Stop current track
	if current_track != null and current_track != audio_stream:
		current_track.on_stop(fade_out, can_destroy)
	else:
		AudioManager.debug._print("DEBUG: Track not found or already playing")
		return
	
	## Play new track
	if audio_stream != null:
		if skip_intro:
			audio_stream.on_play_loop(fade_in, loop_index)
		else:
			audio_stream.on_play(fade_in, skip_intro, loop_index)
			
		current_playback = audio_stream
	
func end_music(sound_name : String, can_fade := false, fade_out := 1.5,
	fade_in := 0.5, can_destroy := false):
		
	if can_fade == false:
		fade_in = 0.0
		fade_out = 0.0
		
	var audio_stream = AudioManager.get_audio_track(sound_name, "abgm")
	if audio_stream != null:
		audio_stream.on_outro(fade_out, fade_in, can_destroy)
	else:
		AudioManager.debug._print("DEBUG: Track not found")
		
	return audio_stream
	
func stop_music(sound_name : String, fade_out := 1.5, can_destroy := false):
	
	var audio_stream = AudioManager.get_audio_track(sound_name, "abgm")
	if audio_stream != null:
		audio_stream.on_stop(fade_out, can_destroy)
	else:
		AudioManager.debug._print("DEBUG: Track not found")



	###########
	## Tools ##
	###########
	
func add_adaptive_track(sound_name : String):
	if !AudioManager.adaptive_bgm.has(sound_name):
		AudioManager.debug._print("DEBUG: Track not found")
		return
	
	var track = AudioManager.get_audio_track(sound_name, "abgm")
	if track != null:
		#AudioManager.debug._print("DEBUG: Track already added to scene")
		return track
	else:
		var instance = AudioManager.adaptive_bgm[sound_name].instantiate()
		AudioManager.abgm_container.add_child(instance)
		return instance
