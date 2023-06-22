extends Node

class_name Transitions

var tween
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
		
func request_change_transition(head_track, from_audio, to_audio, fade_in, fade_out):
	if fade_in != 0.0 or fade_out != 0.0:
		between_fades(head_track, from_audio, to_audio, fade_out, fade_in)
		
		
		
func fade_in(head_track, audio_stream, fade_in := 0.5):
	if tween:
		tween.kill()
	tween = head_track.create_tween()
	audio_stream.volume_db = -50.0
	tween.tween_property(audio_stream, "volume_db", 0.0, fade_in)
	print(fade_in)
	
func between_fades(head_track, stream_out, stream_in, fade_out := 1.5, fade_in := 0.5):
	if tween:
		tween.kill()
	tween = head_track.create_tween().set_parallel(true)
	stream_out.volume_db = 0.0
	stream_in.volume_db = -50.0
	tween.tween_property(stream_out, "volume_db", -50.0, fade_out)
	tween.tween_property(stream_in, "volume_db", 0.0, fade_in)
	tween.chain().tween_callback(stop_section.bind(stream_out))
	
func stop_section(stream):
	stream.stop()
