extends Node2D

func _on_play_pressed():
	AudioManager.play_music("")


func _on_loop_1_pressed():
	AudioManager.change_loop("", 0)


func _on_loop_2_pressed():
	AudioManager.change_loop("", 1)


func _on_outro_pressed():
	AudioManager.to_outro("") 
