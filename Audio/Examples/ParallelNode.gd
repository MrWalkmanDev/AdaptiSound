extends Node2D

func _input(_event):
	if Input.is_action_just_pressed("ui_up"):
		AudioManager.ABGM.play_music("Parallel1")
		#AudioManager.play_music("Main_Menu")
		
	#if Input.is_action_just_pressed("ui_left"):
	#	AudioManager.ABGM.layer_on("Parallel1", ["Staccato"] )
		
	if Input.is_action_just_pressed("ui_right"):
		AudioManager.ABGM.layer_off("Parallel1", [] )
		AudioManager.ABGM.layer_on("Parallel1", ["Drums"] )
		
		var _layer = AudioManager.get_audio_track("Parallel1", "abgm")
			
		
	if Input.is_action_just_pressed("ui_down"):
		AudioManager.ABGM.layer_off("Parallel1", [] )
		AudioManager.ABGM.layer_on("Parallel1", ["Bass"] )
		

func _process(_delta):
	#if($AudioStreamPlayer.stream.get_length() - $AudioStreamPlayer.get_playback_position()) <= 0.01:
	#	print("cambio de pista musical")
	#	$AudioStreamPlayer.play()
	pass
