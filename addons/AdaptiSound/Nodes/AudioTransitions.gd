extends Node

class_name AudioTransitions

func underwater_effect(bus):
	var filter = AudioEffectLowPassFilter.new()
	var bus_index = AudioServer.get_bus_index(bus)
	AudioServer.add_bus_effect(bus_index, filter, AudioServer.get_bus_effect_count(bus_index))
	print(AudioServer.get_bus_effect_count(bus_index))
	#var tween = create_tween()
	#tween.tween_property(effect, "cutoff_hz", 800, 2.0)

func request_play_transition(head_track, audio_stream, fade_in):
	if fade_in != 0.0:
		audio_stream.play()
		fade_in(head_track, audio_stream, fade_in)
	else:
		audio_stream.play()
		
		
func request_change_transition(head_track, from_audio, to_audio, fade_out, fade_in):
	if fade_in != 0.0 or fade_out != 0.0:
		between_fades(head_track, from_audio, to_audio, fade_out, fade_in)
	else:
		from_audio.stop()
		
func fade_in(head_track, audio_stream, fade_in := 0.5, can_tween := true):
	if can_tween:
		if head_track.tween:
			head_track.tween.kill()
	head_track.tween = head_track.create_tween()
	audio_stream.volume_db = -50.0
	head_track.tween.tween_property(audio_stream, "volume_db", head_track.volume_db, fade_in)
	
func fade_out(head_track, audio_stream, fade_out, can_destroy := false):
	#if head_track.tween:
	#	head_track.tween.kill()
	head_track.tween = head_track.create_tween()
	audio_stream.volume_db = head_track.volume_db
	head_track.tween.tween_property(audio_stream, "volume_db", -50.0, fade_out)
	if can_destroy:
		head_track.tween.tween_callback(head_track.destroy_track)
	else:
		head_track.tween.tween_callback(stop_section.bind(audio_stream))
	
func between_fades(head_track, stream_out, stream_in, fade_out := 1.5, fade_in := 0.5):
	if head_track.tween:
		head_track.tween.kill()
	head_track.tween = head_track.create_tween().set_parallel(true)
	stream_out.volume_db = head_track.volume_db
	stream_in.volume_db = -50.0
	head_track.tween.tween_property(stream_out, "volume_db", -50.0, fade_out)
	head_track.tween.tween_property(stream_in, "volume_db", head_track.volume_db, fade_in)
	head_track.tween.chain().tween_callback(stop_section.bind(stream_out))
	
func stop_section(stream):
	stream.stop()
