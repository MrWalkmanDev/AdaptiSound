extends Node

class_name Transitions

#var tween
#var fade_in_time = 0.5
#var fade_out_time = 1.5
#var can_fade_in = false
#var can_fade_out = false
#var can_parallel_fades = false

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
