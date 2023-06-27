extends AudioStreamPlayer

signal audio_finished(node)

var can_loop = true
var tween

func _ready():
	connect("finished", to_loop)

func to_loop():
	if can_loop:
		play()
		emit_signal("audio_finished", self)
	else:
		emit_signal("audio_finished", self)

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
