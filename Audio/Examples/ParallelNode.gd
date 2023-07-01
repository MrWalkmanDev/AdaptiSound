extends Node2D

func _input(_event):
	if Input.is_action_just_pressed("ui_up"):
		AudioManager.play_music("Parallel1")
		
	if Input.is_action_just_pressed("ui_right"):
		#AudioManager.layer_on("Parallel1", ["Bass"], 0.0)
		AudioManager.layer_on("Parallel1", ["Bass"])
		
	if Input.is_action_just_pressed("ui_down"):
		AudioManager.play_layer("Parallel1", ["Bass"])
		
	if Input.is_action_just_pressed("ui_left"):
		#AudioManager.layer_off("Parallel1", ["Bass"], 0.0)
		AudioManager.stop_layer("Parallel1", ["Bass"])

func _process(_delta):
	#if($AudioStreamPlayer.stream.get_length() - $AudioStreamPlayer.get_playback_position()) <= 0.01:
	#	print("cambio de pista musical")
	#	$AudioStreamPlayer.play()
	pass
