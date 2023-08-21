extends Node2D


func _ready():
	pass


func _on_play_1_pressed():
	AudioManager.play_music("ParallelBase")


func _on_play_2_pressed():
	AudioManager.play_music("JazzBase")


func _on_reset_pressed():
	AudioManager.reset_music()


func _on_stop_pressed():
	AudioManager.stop_music(true, 2.0)
