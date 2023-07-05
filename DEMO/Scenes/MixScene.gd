extends Node2D

func _process(_delta):
	pass

func _input(_event):
	if Input.is_action_just_pressed("ui_left"):
		AudioManager.layer_on("BossMusic", ["Staccato"])
	if Input.is_action_just_pressed("ui_right"):
		AudioManager.layer_on("BossMusic", ["Mid"], 0.65)
	if Input.is_action_just_pressed('ui_up'):
		AudioManager.layer_on("BossMusic", ["Top"], 0.75)
	if Input.is_action_just_pressed('ui_down'):
		AudioManager.layer_off("BossMusic", ["Top"])
		AudioManager.layer_off("BossMusic", ["Mid"])
	
func _ready():
	var _track = AudioManager.play_music("BossMusic")
