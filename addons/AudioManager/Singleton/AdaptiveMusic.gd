extends Node

class_name AdaptiveMusic

## Playback Options ##

func play_music(sound_name : String, fade_time := 0.0, skip_intro := false, loop_index := 0):
	var audio_stream = add_adaptive_track(sound_name)
	if audio_stream != null:
		if skip_intro:
			audio_stream.on_play_loop(fade_time, loop_index)
		else:
			audio_stream.on_play(fade_time, skip_intro, loop_index)
		
func change_loop(sound_name, index, fade_in := 0.0, fade_out := 0.0):
	var audio_stream = AudioManager.get_audio_track(sound_name, "abgm")
	if audio_stream != null:
		audio_stream.change_loop(index, fade_in, fade_out)
	else:
		AudioManager.debug._print("DEBUG: Track not found")
		
func change_track(from_track, to_track):
	var current_track = AudioManager.get_audio_track(from_track, "abgm")
	
	if current_track != null:
		current_track.on_stop()
	else:
		AudioManager.debug._print("DEBUG: Track not found")
	
	var audio_stream = add_adaptive_track(to_track)
	if audio_stream != null:
		audio_stream.on_play()
	
func end_music(sound_name : String):
	var audio_stream = AudioManager.get_audio_track(sound_name, "abgm")
	if audio_stream != null:
		audio_stream.on_outro()
	else:
		AudioManager.debug._print("DEBUG: Track not found")
	
func stop_music(sound_name : String):
	var audio_stream = AudioManager.get_audio_track(sound_name, "abgm")
	if audio_stream != null:
		audio_stream.on_stop()
	else:
		AudioManager.debug._print("DEBUG: Track not found")
		


	## Tools ##
	
func add_adaptive_track(sound_name : String):
	if !AudioManager.adaptive_bgm.has(sound_name):
		AudioManager.debug._print("DEBUG: Track not found")
		return
	
	var track = AudioManager.get_audio_track(sound_name, "abgm")
	if track != null:
		AudioManager.debug._print("DEBUG: Track already playing")
	else:
		var instance = AudioManager.adaptive_bgm[sound_name].instantiate()
		AudioManager.abgm_container.add_child(instance)
		return instance
