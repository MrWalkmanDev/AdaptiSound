extends Node

const AUDIO = preload("res://addons/AdaptiSound/Nodes/ParallelTrack/Audio_Stream.tscn")

## Assigning tracks for playback
@export var tracks : Array[AudioStream]

## Play in random queue
@export var random : bool = false

## Assign the first audio to be played. [br]If -1, the first play will be random
@export var first_playback_idx : int = -1

## Here you can edit the parameters for all the tracks that derive from this main track. 
@export_group("MainTrack Parameters")

## Volume of track, in dB. [br][b]This parameter affects all the tracks that belong to it[/b].
@export_range(-80.0, 24.0) var volume_db : float = 0.0 : set = set_volume_db, get = get_volume_db

## Pitch and tempo of the audio. [br][b]This parameter affects all the tracks that belong to it[/b].
@export_range(0.01, 4.0) var pitch : float = 1.0 : set = set_pitch, get = get_pitch

## Audio Bus of the audio. [br][b]This parameter affects all the tracks that belong to it[/b]
@export var bus : String = "Master"

var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	
	for i in tracks:
		var audio_stream = AUDIO.instantiate()
		audio_stream.set_bus(bus)
		audio_stream.can_loop = false
		audio_stream.pitch_scale = pitch
		audio_stream.volume_db = volume_db
		audio_stream.stream = i
		add_child(audio_stream)
		audio_stream.connect("audio_finished", change_track)
	
func on_play(fade_time := 0.0, _skip_intro := false, _loop_index := 0):
	if get_stream_playing() != null:
		AudioManager.debug._print("DEBUG: " + str(self.name) + " already playing")
		return
	
	if get_child_count() == 0:
		AudioManager.debug._print("DEBUG: " + str(self.name) + " no tracks added")
		return
	
	if first_playback_idx != -1:
		if first_playback_idx > tracks.size() - 1:
			AudioManager.debug._print("DEBUG: " + str(self.name) + " index not found")
			return
		var audio = get_children()[first_playback_idx]
		audio.play()
	
	else:
		var num = rng.randi_range(0, tracks.size() - 1)
		var audio = get_children()[num]
		audio.play()
		
func on_stop(fade_time := 0.0, _can_destroy := false):
	if get_child_count() == 0:
		AudioManager.debug._print("DEBUG: " + str(self.name) + " no tracks added")
		return
		
	for i in get_children():
		i.stop()

func change_track(node):
	if random:
		var num = rng.randi_range(0, tracks.size() - 1)
		if num == get_children().find(node):
			num += 1
			if num > tracks.size() - 1:
				num = 0
		var audio = get_children()[num]
		audio.play()
		
	else:
		var index = get_children().find(node)
		index += 1
		if index > tracks.size() - 1:
			index = 0
		var audio = get_children()[index]
		audio.play()

func get_stream_playing():
	var childs = get_children()
	for i in childs:
		if i.playing:
			return i
			
	return null

func set_volume_db(value : float):
	volume_db = value
	for i in get_children():
		for n in i.get_children():
			n.volume_db = volume_db
			
		i.volume_db = volume_db
	
func get_volume_db():
	return volume_db

func set_pitch(value):
	pitch = value
	for i in get_children():
		for n in i.get_children():
			n.pitch = pitch
			
		i.pitch = pitch
	
func get_pitch():
	return pitch
