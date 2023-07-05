extends Node2D

func _on_play_pressed():
	AudioManager.play_music("Battle", 0.0, 0.0, 1.5)


func _on_loop_1_pressed():
	AudioManager.change_loop("Battle", 0, true, 0.0)


func _on_loop_2_pressed():
	AudioManager.change_loop("Battle", 1, true, 0.0)


func _on_outro_pressed():
	AudioManager.to_outro("Battle")
