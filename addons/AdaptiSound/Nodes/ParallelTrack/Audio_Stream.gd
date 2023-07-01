extends AudioStreamPlayer

signal audio_finished(node)

var loop : bool = true : set = set_loop, get = get_loop
var destroy : bool = false : set = set_destroy, get = get_destroy
var mute = false

var tween
var can_change = true

func _ready():
	#connect("finished", can_destroy_track)
	pass
	
func _process(delta):
	if stream != null and self.playing:
		if(self.stream.get_length() - self.get_playback_position()) <= 0.01 and can_change:
			can_change = false
			to_loop()
			
	if mute:
		volume_db = -50.0

func to_loop():
	#print("Loop Signal" + self.name)
	if loop:
		play()
		emit_signal("audio_finished", self)
		can_change = true
	else:
		emit_signal("audio_finished", self)
		can_change = true

func on_fade_in(volume, fade := 0.5):
	if tween:
		tween.kill()
	tween = create_tween().set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "volume_db", volume, fade)

func on_fade_out(fade := 1.5, can_stop := true):
	if tween:
		tween.kill()
	tween = create_tween().set_ease(Tween.EASE_IN)
	tween.tween_property(self, "volume_db", -50.0, fade)
	if can_stop:
		tween.tween_callback(on_stop)

func on_stop():
	stop()
	if destroy:
		queue_free()



#########################
## SETTERS AND GETTERS ##
#########################

## LOOP
func set_loop(value : bool):
	loop = value
	return self
	
func get_loop():
	return loop
	
func set_bus(value):
	bus = value
	return self

func set_volume_db(value):
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

func set_mute(value : bool):
	mute = value
