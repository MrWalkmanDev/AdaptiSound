extends Node2D

func _ready():
	pass


func _on_play_pressed():
	#AudioManager.add_track("JazzBase").set_volume_db(0.0)
	AudioManager.play_music("JazzBase")


func _on_stop_pressed():
	AudioManager.play_music("Battle")
