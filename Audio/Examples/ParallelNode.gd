extends Node2D

func _process(_delta):
	#print(AudioManager.current_playback)
	pass

func _input(_event):
	if Input.is_action_just_pressed("ui_up"):
		AudioManager.play_music("Parallel1")
		#AudioManager.play_sound("Main_Menu").set_bus("xd")
		
	if Input.is_action_just_pressed("ui_right"):
		AudioManager.play_music("Theme1")
		
	if Input.is_action_just_pressed("ui_down"):
		var track = AudioManager.get_audio_track("Theme1")
		track.connect("end_track", start_music)
		AudioManager.to_outro("Theme1").set_secuence("Parallel1")
		#AudioManager.stop_music(true)
		#AudioManager.play_music("Parallel1")
		#AudioManager.layer_on("Parallel1", ["Bass"])
		#AudioManager.to_outro("Theme1")#.set_secuence("Parallel1")
		#AudioManager.get_audio_track("Theme1").connect("end_track", start_music)
		
	if Input.is_action_just_pressed("ui_left"):
		AudioManager.play_music("Theme1")

func start_music():
	if AudioManager.get_audio_track("Theme1").is_connected("end_track", start_music):
		AudioManager.get_audio_track("Theme1").disconnect("end_track", start_music)
	AudioManager.play_music("Parallel1")
	AudioManager.layer_on("Parallel1", ["Bass"])
