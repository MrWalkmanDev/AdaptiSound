extends AudioStreamPlayer

signal audio_finished(node)

var can_loop = true
var tween
var can_change = true

func _ready():
	#stream.set_loop(can_loop)
	#connect("finished", to_loop)
	pass
	
func _process(delta):
	if stream != null and self.playing:
		if(self.stream.get_length() - self.get_playback_position()) <= 0.01 and can_change:
			can_change = false
			to_loop()

func to_loop():
	#print("Loop Signal" + self.name)
	if can_loop:
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
		tween.tween_callback(stop)
