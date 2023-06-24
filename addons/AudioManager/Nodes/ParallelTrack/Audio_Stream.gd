extends AudioStreamPlayer

signal audio_finished(node)

var can_loop = true

func _ready():
	connect("finished", to_loop) 

func to_loop():
	if can_loop:
		play()
		emit_signal("audio_finished", self)
