extends AudioStreamPlayer

signal audio_finished(node)

var loop : bool = true : set = set_loop, get = get_loop
var destroy : bool = false : set = set_destroy, get = get_destroy

var tween
var can_change = true

var groups = []

var sequence = false
var method_sequence : Callable

## for volume manager
var on_mute = false

## for random sequencer
var random_sequence = false

func _ready():
	if stream != null:
		if !stream is AudioStreamWAV:
			stream.loop = loop

func on_fade_in(volume, fade := 0.5):
	#print(self.name + "in")
	if tween:
		tween.kill()
		
	if fade == 0.0:
		return
		
	if playing == false:
		volume_db = -50.0
	tween = create_tween()#.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "volume_db", volume, fade)

func on_fade_out(fade := 1.5, can_stop := true):
	#print(self.name + "out")
	if tween:
		tween.kill()
		
	if fade == 0.0:
		on_stop()
		return
	
	tween = create_tween()#.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "volume_db", -50.0, fade)
	if can_stop:
		tween.tween_callback(on_stop)
		
func stop_tween():
	if tween:
		tween.kill()

func on_stop():
	stop()
	if destroy:
		queue_free()


## Set Sequence ##
func set_sequence(method : Callable):
	sequence = true
	method_sequence = method

func _on_finished():
	if sequence:
		method_sequence.call()
	if random_sequence:
		emit_signal("audio_finished", self)



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
	
func set_bus(value):
	bus = value
	return self

func set_volume_db(value):
	if tween:
		tween.kill()
	volume_db = value
	return self

func set_pitch_scale(value):
	pitch_scale = value
	return self

func set_destroy(value):
	destroy = value
	if playing == false:
		on_stop()
	
func get_destroy():
	return destroy


