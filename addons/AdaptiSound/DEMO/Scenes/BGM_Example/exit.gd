extends Area2D

func _on_body_entered(body):
	if body.is_in_group("Player"):
		get_tree().change_scene_to_file("res://DEMO/Scenes/BGM_Example/lvl_2.tscn")
