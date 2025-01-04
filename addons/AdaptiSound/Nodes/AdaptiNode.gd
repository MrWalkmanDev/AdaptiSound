extends Node

class_name AdaptiNode

## Specifies the process frame update.
## [br][b]Use for Measure Count system, sequence and destroy system.[/b]
@export_enum("Idle", "Physics") var process_callback = 0

@export_subgroup("Debug")
## Show measure count system
@export var show_measure_count : bool = true



## -------------------------------------------------------------------------------------------------
## Volume of track, in dB. [br][b]This parameter affects all the tracks that belong to it[/b].
var volume_db : float = 0.0 : set = set_volume_db, get = get_volume_db

## Pitch and tempo of the audio. [br][b]This parameter affects all the tracks that belong to it[/b].
var pitch_scale : float = 1.0 : set = set_pitch_scale, get = get_pitch_scale

## Audio Bus of the audio. [br][b]This parameter affects all the tracks that belong to it[/b]
var bus : String = "Master" : set = set_bus, get = get_bus

## If true, one track is on play
var playing : bool = false

## If true, the track when stopped will be destroyed
var destroy : bool = false : set = set_destroy, get = get_destroy

##  If true, the track when stopped will start other track
var sequence = false
var method_sequence : Callable


## -------------------------------------------------------------------------------------------------
func _process(delta):
	if process_callback == 0:
		check_track_is_playing()
		
func _physics_process(delta):
	if process_callback == 1:
		check_track_is_playing()

func check_track_is_playing():
	#if sequence or destroy:
	if get_stream_playing() == null:
		playing = false
		if sequence:
			sequence = false
			method_sequence.call()
		if destroy:
			destroy = false
			destroy_track()
	else:
		playing = true
				
#########################
## SETTERS AND GETTERS ##
#########################

## Volume db
func set_volume_db(value : float):
	volume_db = value
	#for i in get_children():
		#if i is AudioStreamPlayer:
			#if i.on_mute == false:
				#if i.tween:
					#i.tween.kill()
				#i.volume_db = volume_db
		#else:
			#i.volume_db = volume_db
		
	return self
	
func get_volume_db():
	return volume_db

## Pitch Scale
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


## DESTROY SYSTEM ##
func set_destroy(value: bool):
	destroy = value
	
func get_destroy():
	return destroy
		
func destroy_track():
	queue_free()
	

## Get AdaptiAudioStreamPlayers on playing ##
func get_stream_playing():
	for i in get_children():
		if i is AdaptiAudioStreamPlayer:
			if i.playing:
				return i
		else:
			return i.get_stream_playing()
	return null
