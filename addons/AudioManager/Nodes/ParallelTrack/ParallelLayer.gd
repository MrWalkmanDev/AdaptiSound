extends AudioStreamPlayer

const AUDIO = preload("res://addons/AudioManager/Nodes/ParallelTrack/Audio_Stream.tscn")

## Choose the type of layer 
##[br][b]Always[/b]: Plays when calling [b]on_play()[/b]
##[br][b]Trigger[/b]: Is playing with a specific command
@export_enum("Always", "Trigger") var playing_type : String = "Always"

## Choose the number of tracks that will be played on this layer
@export var audio_streams : Array[AudioStream]

## If false, it will not be heard when calling [b]on_play()[/b]
@export var listening_from_start = true

## Choose if the layer is a loop
@export var can_loop = true

## Select group of layer
@export_group("Groups")
@export var groups : Array[String]

var tween

func _ready():
	connect("finished", to_loop) 
	
	if audio_streams != []:
		for i in audio_streams:
			var audio_stream = AUDIO.instantiate()
			audio_stream.can_loop = can_loop
			audio_stream.stream = i
			add_child(audio_stream)

func to_loop():
	if can_loop:
		play()

func on_play(fade_time, volume):
	if get_child_count() > 0: 
		for i in get_children():
			if fade_time != 0.0:
				i.volume_db = -50.0
				i.play()
				change(volume, fade_time)
			else:
				i.play()
			
	else:
		if fade_time != 0.0:
			volume_db = -50.0
			play()
			change(volume, fade_time)
		else:
			play()

func change(volume, fade_time, fade_type := true, can_stop := true):
	if fade_type:
		if get_child_count() > 0:
			for i in get_children():
				i.on_fade_in(volume, fade_time)
		else:
			on_fade_in(volume, fade_time)
	else:
		if get_child_count() > 0:
			for i in get_children():
				i.on_fade_out(fade_time, can_stop)
		else:
			on_fade_out(fade_time, can_stop)
		

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
