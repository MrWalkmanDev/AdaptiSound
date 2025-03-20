@tool
extends Resource
class_name BeatSystemResource

signal BeatChanged(value)
signal BarChanged(value)
signal LoopBegin

@export var bpm : int = 120 : set = set_bpm
#@export var total_beat_count : int = 16
@export var beats_per_bar : int = 4


var song_position = 0.0
var song_position_in_beats = 1
var sec_per_beat : float = 0.0
var last_reported_beat = 0
var beats_before_start = 0

var can_beat = false
var can_first_beat : bool = true
var _beat = 0
var beat_measure_count = 1
var measures = 1

var can_beat_count : bool = true
var current_beat_count:int=0

func _init():
	reset_beat_parameters(bpm)

func beat_process(delta, current_playback:AudioStreamPlayer):
	song_position = current_playback.get_playback_position()\
	+ AudioServer.get_time_since_last_mix()
	song_position -= AudioServer.get_output_latency()
	song_position_in_beats = int(floor(song_position / sec_per_beat)) + beats_before_start
	
	report_beat()

func report_beat():
	if current_beat_count != song_position_in_beats and song_position_in_beats >= 0:
		can_beat_count = true
	if can_beat_count and song_position_in_beats >= 0:
		current_beat_count = song_position_in_beats
		can_beat_count = false
		BeatChanged.emit(current_beat_count)
	
	## First Beat (Loop) ##
	if song_position_in_beats <= 0 \
	#and last_reported_beat == total_beat_count - 1 \
	and can_first_beat:
		can_first_beat = false
		_beat = 0
		beat_measure_count = 1
		measures = 1
		
		LoopBegin.emit()
		
		#change_track_by_key(current_loop_index)
	if _beat < song_position_in_beats:
		can_beat = true
	
	## Beat Report ##
	if can_beat:
		can_beat = false
		_beat += 1
		beat_measure_count += 1
		if beat_measure_count > beats_per_bar:
			measures += 1
			beat_measure_count = 1
			can_first_beat = true
			#change_track_by_key(current_loop_index)
			BarChanged.emit(measures)
		
		last_reported_beat = song_position_in_beats
		


func reset_beat_parameters(_bpm:int):
	can_first_beat = true
	beat_measure_count = 1
	measures = 1
	last_reported_beat = 0
	song_position_in_beats = 0
	_beat = 0
	sec_per_beat = 60.0 / _bpm


func set_bpm(value):
	bpm = value
	sec_per_beat = 60.0 / bpm
