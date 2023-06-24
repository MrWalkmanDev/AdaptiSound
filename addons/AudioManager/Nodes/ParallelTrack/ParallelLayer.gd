extends AudioStreamPlayer

const AUDIO = preload("res://addons/AudioManager/Nodes/ParallelTrack/Audio_Stream.tscn")

@export_enum("Always", "Trigger") var type : String = "Always"

@export var audio_streams : Array[AudioStream]
@export var can_loop = true

func _ready():
	connect("finished", to_loop) 

func to_loop():
	print("Layer Loop")
	if can_loop:
		play()

func on_play():
	if audio_streams != []:
		for i in audio_streams:
			var audio_stream = AUDIO.instantiate()
			#audio_stream.loop = can_loop
			audio_stream.stream = i
			add_child(audio_stream)
			audio_stream.play()
			
	else:
		play()
