extends Node2D

func _ready():
	pass


func _on_play_pressed():
	AudioManager.add_track("Battle").set_volume_db(-60.0)
	AudioManager.play_music("Battle")


func _on_stop_pressed():
	AudioManager.play_music("JazzBase")
