extends Node2D

@export var audio : AudioStream
@export var adaptive_scene : PackedScene
@export var sfx : AudioStream

func _ready():
	pass
	#AudioManager.load_audio_from_stream(audio, "JazzBase", AudioManager.BGM)
	#AudioManager.load_audio_from_stream(sfx, "Rain", AudioManager.BGS)
	#AudioManager.load_audio_from_packedscene(adaptive_scene, "Track_01", AudioManager.BGM)

func _on_play_pressed():
	AudioManager.play_music("Swing")
	AudioManager.mute_layer("Swing", [], true, 1.0) ## Mute All Layers
	AudioManager.mute_layer("Swing", [0], false, 1.0) ## Unmute the layer you can hear
	#AudioManager.change_loop("theme", "clip1", 0.7, 1.0) # change loop by name

func _on_play_2_pressed():
	#AudioManager.change_loop("theme", 2, 0.7, 1.0) # change clip by index
	AudioManager.mute_layer("Swing", ["melody"], false, 1.0)

func _on_stop_pressed():
	#AudioManager.stop_all()
	AudioManager.stop_music(1.0)
