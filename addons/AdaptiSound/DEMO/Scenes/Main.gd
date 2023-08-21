extends Node2D

const ENEMY = preload("res://addons/AdaptiSound/DEMO/Prefabs/skeleton.tscn")

@onready var enemy_container = get_node("Node2D")

var music_zone = "Forest"
var combat = false

var parallel_track_name : String = "AdaptiParallel"#"Parallel(Example)"

func _ready():
	AudioManager.play_music(parallel_track_name)

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
	AudioManager.play_music("Battle", 0.5, 1.5, true) # Without Intro
	#AudioManager.play_music("Battle")                # With Intro
	AudioManager.change_loop("Battle", 0, true)

func off_combat():
	AudioManager.set_sequence(reset_theme)
	AudioManager.set_destroy(true)
	AudioManager.to_outro("Battle")#.set_destroy(true)
	
	
func reset_theme():
	AudioManager.play_music(parallel_track_name)
	AudioManager.mute_layer(parallel_track_name, [music_zone], false, 0.5)
	
func _on_button_pressed():
	var instance = ENEMY.instantiate()
	var spawn_position = $CanvasLayer/Control/Panel.get_viewport().get_canvas_transform()
	instance.position = -spawn_position[2] + $CanvasLayer/Control/Panel.position
	enemy_container.add_child(instance)
	


## PARALLELTRACK ##

func _on_forest_body_entered(body):
	if body.is_in_group("Player"):
		AudioManager.mute_layer(parallel_track_name, [], true)
		AudioManager.mute_layer(parallel_track_name, ["Forest"], false, 0.5)
		music_zone = "Forest"

func _on_ice_body_entered(body):
	if body.is_in_group("Player"):
		AudioManager.mute_layer(parallel_track_name, [], true)
		AudioManager.mute_layer(parallel_track_name, ["Freeze"], false, 0.5)
		music_zone = "Freeze"

func _on_desert_body_entered(body):
	if body.is_in_group("Player"):
		AudioManager.mute_layer(parallel_track_name, [], true)
		AudioManager.mute_layer(parallel_track_name, ["Desert"], false, 0.5)
		music_zone = "Desert"

func _on_volvano_body_entered(body):
	if body.is_in_group("Player"):
		AudioManager.mute_layer(parallel_track_name, [], true)
		AudioManager.mute_layer(parallel_track_name, ["Volcano"], false, 0.5)
		music_zone = "Volcano"



	## VOLUME MANAGER ##

func _on_area_2d_body_entered(_body):
	## With Bus Volume
	#with_bus_volume(-10.0)
	
	## With Track Volume
	with_track_volume(-10.0)

func _on_area_2d_body_exited(_body):
	## With Bus Volume
	#with_bus_volume(0.0)
		
	## With Track Volume
	with_track_volume(0.0)
	

func with_bus_volume(target_volume):
	var vol = AudioManager.get_track_bus_volume_db()
	var index = AudioManager.get_track_bus_index()
	if AudioManager.current_playback != null: # (if AudioManager.current_playnback is null, vol will be null)
		var tween = create_tween()
		tween.tween_method(AudioManager.set_bus_volume_db.bind(index), vol, target_volume, 1.5)
	
func with_track_volume(target_volume):
	if AudioManager.current_playback != null:
		var tween = create_tween()
		tween.tween_property(AudioManager.current_playback, "volume_db", target_volume, 1.5)





# Change Scene #
func _on_exit_body_entered(body):
	if body.is_in_group("Player"):
		get_tree().change_scene_to_file("res://DEMO/Scenes/AdaptiveScene.tscn")
