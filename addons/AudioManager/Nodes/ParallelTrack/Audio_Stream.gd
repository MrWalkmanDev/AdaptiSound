extends AudioStreamPlayer

var can_loop = true

func _ready():
	connect("finished", to_loop) 

func to_loop():
	if can_loop:
		play()
