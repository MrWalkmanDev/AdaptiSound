@tool
extends AudioStreamPlayer
class_name AdaptiAudioStreamPlayer

signal audio_finished(node)

var loop : bool = true : set = set_loop, get = get_loop
var destroy : bool = false : set = set_destroy, get = get_destroy

var tween : Tween
var can_change = true

var groups = []

var sequence = false
var method_sequence : Callable

## for volume manager
var on_mute = false

## for random sequencer
var random_sequence = false


## -------------------------------------------------------------------------------------------------
## Initialization
func _ready():
	finished.connect(_on_finished)
	if stream != null:
		if !stream is AudioStreamWAV:
			stream.loop = loop


## -------------------------------------------------------------------------------------------------
######################
## PLAYBACK METHODS ##
######################

func on_play(value:=0.0):
	play(value)
	
	
## -------------------------------------------------------------------------------------------------
func on_stop():
	stop()
	tween = null
	if destroy:
		queue_free()


## -------------------------------------------------------------------------------------------------
func on_fade_in(volume, fade_time := 0.5, _from:=volume_db):
	#print(self.name + str(volume))
	if tween:
		tween.kill()
		_from = volume_db
	else:
		_from = -50.0
		
	if fade_time == 0.0:
		volume_db = volume
		return
		
	if playing == false:
		volume_db = -50.0
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "volume_db", volume, fade_time).from(_from)


## -------------------------------------------------------------------------------------------------
func on_fade_out(fade_time := 1.5, can_stop := true):
	#print(self.name + "out")
	if tween:
		tween.kill()
		
	if fade_time == 0.0:
		if can_stop:
			on_stop()
		else:
			volume_db = -50.0
		return
		
	tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "volume_db", -50.0, fade_time)
	if can_stop:
		tween.tween_callback(on_stop)



## -------------------------------------------------------------------------------------------------
######################
## SEQUENCE METHODS ##
######################

func set_sequence(method : Callable):
	sequence = true
	method_sequence = method
	
func stop_tween():
	if tween:
		tween.kill()

func _on_finished():
	if sequence:
		method_sequence.call()
	if random_sequence:
		emit_signal("audio_finished", self)



## -------------------------------------------------------------------------------------------------
#########################
## SETTERS AND GETTERS ##
#########################

## LOOP
func set_loop(value : bool):
	loop = value
	if !stream is AudioStreamWAV and stream != null:
		stream.set_loop(value)
	return self
	
func get_loop():
	return loop

## BUSES
func set_bus(value):
	bus = value
	return self

## VOLUME_DB
func set_volume_db(value):
	if tween:
		tween.kill()
	volume_db = value
	return self

## PITCH SCALE
func set_pitch_scale(value):
	pitch_scale = value
	return self

## If true, track is queue_free once time to stopped
func set_destroy(value):
	destroy = value
	if playing == false:
		on_stop()
	
func get_destroy():
	return destroy
