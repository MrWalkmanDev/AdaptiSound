extends Node2D

func _input(_event):
	if Input.is_action_just_pressed("ui_up"):
		AudioManager.play_sound("Main_Menu")
		
	if Input.is_action_just_pressed("ui_right"):
		AudioManager.layer_on("Parallel1", ["Bass"], 0.0)
		
	if Input.is_action_just_pressed("ui_down"):
		AudioManager.stop_music()
		
	if Input.is_action_just_pressed("ui_left"):
		AudioManager.layer_off("Parallel1", ["Bass"], 0.0)

func _process(_delta):
	#if($AudioStreamPlayer.stream.get_length() - $AudioStreamPlayer.get_playback_position()) <= 0.01:
	#	print("cambio de pista musical")
	#	$AudioStreamPlayer.play()
	pass
