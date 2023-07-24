extends Node

class_name AdaptiNode

# Here you can edit the parameters for all the tracks that derive from this main track. 
#@export_group("MainTrack Parameters")

## Volume of track, in dB. [br][b]This parameter affects all the tracks that belong to it[/b].
@export_range(-80.0, 24.0) var volume_db : float = 0.0 : set = set_volume_db, get = get_volume_db

## Pitch and tempo of the audio. [br][b]This parameter affects all the tracks that belong to it[/b].
@export_range(0.01, 4.0) var pitch_scale : float = 1.0 : set = set_pitch_scale, get = get_pitch_scale


@export_subgroup("Debug")
## Show measure count system
@export var show_measure_count : bool = true

## Audio Bus of the audio. [br][b]This parameter affects all the tracks that belong to it[/b]
var bus : String = "Master" : set = set_bus, get = get_bus

## If true, the track when stopped will be destroyed
var destroy : bool = false

##  If true, the track when stopped will start other track
var sequence = false
var method_sequence : Callable

func _process(delta):
	check_track_is_playing()

func check_track_is_playing():
	if sequence or destroy:
		if get_stream_playing() == null:
			if sequence:
				sequence = false
				method_sequence.call()
			if destroy:
				destroy = false
				destroy_track()

func set_volume_db(value : float):
	volume_db = value
	for i in get_children():
		if i is AudioStreamPlayer:
			if i.on_mute == false:
				if i.tween:
					i.tween.kill()
				i.volume_db = volume_db
		else:
			i.volume_db = volume_db
		
	return self
	
func get_volume_db():
	return volume_db
	
func set_pitch_scale(value):
	pitch_scale = value
	for i in get_children():
		i.pitch_scale = pitch_scale
		
	return self

func get_pitch_scale():
	return pitch_scale
	
	
	## Audio Bus ##
	
func set_bus(value : String):
	var buses = AudioServer.bus_count
	var buses_arr = []
	for i in buses:
		var bus_name = AudioServer.get_bus_name(i)
		buses_arr.append(bus_name)

	if buses_arr.has(value):
		bus = value
		for i in get_children():
			i.bus = value
			
	return self

func get_bus():
	return bus

func set_destroy(value: bool):
	destroy = value
	#if get_stream_playing() == null and destroy:
	#	destroy_track()
		
func destroy_track():
	#for i in get_children():
	#	if i is AudioStreamPlayer:
	#		i.stop()
		
	queue_free()

func get_stream_playing():
	for i in get_children():
		if i is AudioStreamPlayer:
			if i.playing:
				return i
		else:
			return i.get_stream_playing()
			
	return null
