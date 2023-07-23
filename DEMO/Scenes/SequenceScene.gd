extends Node2D

func _on_play_pressed():
	AudioManager.play_music("Sequence(Example)", 0.0)

func _on_stop_pressed():
	AudioManager.stop_music(true)
