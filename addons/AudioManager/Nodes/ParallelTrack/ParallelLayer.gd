extends AudioStreamPlayer

const AUDIO = preload("res://addons/AudioManager/Nodes/ParallelTrack/Audio_Stream.tscn")

## Choose the type of layer 
##[br]Always: It is constantly playing 
##[br]Trigger: Is playing with a specific command
@export_enum("Always", "Trigger") var type : String = "Always"

## Choose the number of tracks that will be played on this layer
@export var audio_streams : Array[AudioStream]

## If true, it will be played when calling on_play()
@export var play_on_start = true

## Choose if the layer is a loop
@export var can_loop = true

var tween

func _ready():
	connect("finished", to_loop) 

func to_loop():
	#print("Layer Loop")
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


func on_fade_in(fade):
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(self, "volume_db", 0.0, fade)

func on_fade_out(fade):
	tween = create_tween()
	tween.tween_property(self, "volume_db", -50.0, fade)
