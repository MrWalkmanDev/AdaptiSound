extends Node2D

const ENEMY = preload("res://DEMO/Prefabs/skeleton.tscn")

@onready var enemy_container = get_node("Node2D")

var music_zone = "Forest"
var combat = false

func _ready():
	AudioManager.play_music("Parallel(Example)")


## BATTLE ADAPTIVETRACK ##
func _process(_delta):
	var enemies = get_tree().get_nodes_in_group("Enemy")
	if enemies != []:
		if !combat:
			combat = true
			on_combat()
	else:
		if combat:
			combat = false
			off_combat()
		
func on_combat():
	AudioManager.play_music("Battle", 0.0, 0.5, 1.5, true) # Without Intro
	#AudioManager.play_music("Battle")                       # With Intro
	AudioManager.change_loop("Battle", 0, true)
	
func off_combat():
	var track = AudioManager.get_audio_track("Battle")
	if !track.is_connected("end_track", reset_theme):
		track.connect("end_track", reset_theme.bind(track))
	AudioManager.to_outro("Battle")
	
	#AudioManager.play_music("Parallel(Example)")
	#AudioManager.layer_on("Parallel(Example)", [music_zone])
		
func reset_theme(track):
	if track.is_connected("end_track", reset_theme):
		track.disconnect("end_track", reset_theme)
	AudioManager.play_music("Parallel(Example)")
	AudioManager.layer_on("Parallel(Example)", [music_zone], 0.5)
	
func _on_button_pressed():
	var instance = ENEMY.instantiate()
	var spawn_position = $CanvasLayer/Control/Panel.get_viewport().get_canvas_transform()
	instance.position = -spawn_position[2] + $CanvasLayer/Control/Panel.position
	enemy_container.add_child(instance)
	


## PARALLELTRACK ##

func _on_forest_body_entered(body):
	if body.is_in_group("Player"):
		AudioManager.layer_off("Parallel(Example)", [])
		AudioManager.layer_on("Parallel(Example)", ["Forest"], 0.5)
		music_zone = "Forest"

func _on_ice_body_entered(body):
	if body.is_in_group("Player"):
		AudioManager.layer_off("Parallel(Example)", [])
		AudioManager.layer_on("Parallel(Example)", ["Freeze"], 0.5)
		music_zone = "Freeze"

func _on_desert_body_entered(body):
	if body.is_in_group("Player"):
		AudioManager.layer_off("Parallel(Example)", [])
		AudioManager.layer_on("Parallel(Example)", ["Desert"], 0.5)
		music_zone = "Desert"

func _on_volvano_body_entered(body):
	if body.is_in_group("Player"):
		AudioManager.layer_off("Parallel(Example)", [])
		AudioManager.layer_on("Parallel(Example)", ["Volcano"], 0.5)
		music_zone = "Volcano"



	## VOLUME MANAGER ##

func _on_area_2d_body_entered(_body):
	var vol = AudioManager.get_track_bus_volume_db()
	var index = AudioManager.get_track_bus_index()
	if vol != null:
		var tween = create_tween()
		tween.tween_method(AudioManager.set_bus_volume_db.bind(index), vol, -10.0, 1.5)

func _on_area_2d_body_exited(_body):
	var vol = AudioManager.get_track_bus_volume_db()
	var index = AudioManager.get_track_bus_index()
	if vol != null:
		var tween = create_tween()
		tween.tween_method(AudioManager.set_bus_volume_db.bind(index), vol, 0.0, 1.5)




# Change Scene #
func _on_exit_body_entered(body):
	if body.is_in_group("Player"):
		get_tree().change_scene_to_file("res://DEMO/Scenes/AdaptiveScene.tscn")
