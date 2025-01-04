extends Node


const AUDIO = preload("res://addons/AdaptiSound/Nodes/AudioSynchronizedPlayer/Audio_Stream.tscn")
const SAVE_PATH = "res://addons/AdaptiSound/Panel/Data.json"


## -------------------------------------------------------------------------------------------------
## Add music or bgs track on tree
func add_track(sound_name : String, track_data : Dictionary):
	var track = AudioManager.get_audio_track(sound_name)
	if track != null:
		return track
	else:
		var audio_stream
		var type = track_data["type"]
		if type == "BGM":
			if track_data["file"] is PackedScene:
				audio_stream = track_data["file"].instantiate()
			else:
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


## -------------------------------------------------------------------------------------------------
## Queue free nodes
func destroy_audiostream(track):
	if track != null:
		track.queue_free()


## -------------------------------------------------------------------------------------------------
## FADE IN
func check_fade_in(node, vol_db:float, fade_time:float):
	if node is AdaptiAudioStreamPlayer:
		node.on_fade_in(vol_db, fade_time)
		node.play()
	else:
		node.on_play(fade_time, vol_db)
		node.playing = true

## FADE OUT
func check_fade_out(node, fade_time:float, can_destroy := false):
	if node is AdaptiAudioStreamPlayer:
		node.set_destroy(can_destroy)
		node.on_fade_out(fade_time)
	else:
		node.on_stop(fade_time, can_destroy)


## -------------------------------------------------------------------------------------------------
## Fades for Stop_All Function
func fades_out(object, value, fade_time, destroy := false):
	if object is AdaptiAudioStreamPlayer:
		object.destroy = destroy
		object.on_fade_out(fade_time)
	else:
		object.on_stop(fade_time, destroy)


## -------------------------------------------------------------------------------------------------
## Load Panel Data info
func load_json():
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file_access := FileAccess.open(SAVE_PATH, FileAccess.READ)
	var json_data := file_access.get_line()
	file_access.close()
	var data: Dictionary = JSON.parse_string(json_data)
	return data
