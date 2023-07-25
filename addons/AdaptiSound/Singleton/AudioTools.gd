extends Node

const AUDIO = preload("res://addons/AdaptiSound/Nodes/ParallelTrack/Audio_Stream.tscn")
const SAVE_PATH = "res://addons/AdaptiSound/Panel/Data.json"

## Check if can use Fade_In or Fade_Out
func check_fade(node, fade_time, type: bool, skip_intro := false, loop_index := 0):
	if type:
		if node is AudioStreamPlayer:
			node.on_fade_in(0.0, fade_time)
			node.play()
		else:
			node.on_play(fade_time, skip_intro, loop_index)
	else:
		if node is AudioStreamPlayer:
			node.on_fade_out(fade_time)
			node.stop()
		else:
			node.on_stop(fade_time)

## Add music or bgs track on tree
func add_track(sound_name : String, track_data : Dictionary):
	var track = AudioManager.get_audio_track(sound_name)
	if track != null:
		return track
	else:
		var audio_stream
		var type = track_data["type"]
		if type == "ABGM":
			audio_stream = track_data["file"].instantiate()
			
		elif type == "BGM":
			audio_stream = AUDIO.instantiate()
			audio_stream.stream = track_data["file"]
		
		elif type == "BGS":
			if track_data["file"] is PackedScene:
				audio_stream = track_data["file"].instantiate()
			else:
				audio_stream = AUDIO.instantiate()
				audio_stream.stream = track_data["file"]
			
		track_data["container"].add_child(audio_stream)
		audio_stream.name = sound_name
		audio_stream.bus = track_data.bus
		return audio_stream

## Fades for Stop_All Function
func fades(object, value, fade_time, destroy := false):
	var tween = AudioManager.create_tween()
	tween.tween_property(object, "volume_db", value, fade_time)
	if destroy:
		tween.tween_callback(destroy_audiostream.bind(object))

## Queue free nodes
func destroy_audiostream(track):
	if track != null:
		track.queue_free()

## Load Panel Data info
func load_json():
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file_access := FileAccess.open(SAVE_PATH, FileAccess.READ)
	var json_data := file_access.get_line()
	file_access.close()
	var data: Dictionary = JSON.parse_string(json_data)
	return data
