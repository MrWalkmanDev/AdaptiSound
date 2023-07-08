extends Area2D



func _on_body_entered(body):
	if body.is_in_group("Player"):
		AudioManager.stop_music(true)


func _on_body_exited(body):
	if body.is_in_group("Player"):
		AudioManager.play_music("JazzBase")
