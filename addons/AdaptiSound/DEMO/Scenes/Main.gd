extends Node2D

const ENEMY = preload("res://addons/AdaptiSound/DEMO/Prefabs/skeleton.tscn")

@onready var enemy_container = get_node("Node2D")

var music_zone = "Forest"
var combat = false

var parallel_track_name : String = "AdaptiParallel"

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

	## Other Way to Sequence a method ##
	#var track = AudioManager.get_audio_track("Battle")
	#if track:
		#if !track.playing:
			#back_to_main_theme()
		
func on_combat():
	## Without Intro
	AudioManager.create_audio_track("Battle").set_skip_intro(true)
	AudioManager.play_music("Battle", 0.0, 0.5)
	
	## With Intro
	##AudioManager.play_music("Battle")                         
	
	## Create Battle track and change to loop if plays Outro ##
	AudioManager.change_loop("Battle", 0, true)

func off_combat():
	## Set method in sequence after outro plsying ##
	AudioManager.set_sequence(back_to_main_theme)
	AudioManager.to_outro("Battle", 0.0, 0.0)
	
	
func back_to_main_theme():
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
		AudioManager.mute_layer(parallel_track_name, [], true, 0.5)
		AudioManager.mute_layer(parallel_track_name, ["Forest"], false, 0.5)
		music_zone = "Forest"

func _on_ice_body_entered(body):
	if body.is_in_group("Player"):
		AudioManager.mute_layer(parallel_track_name, [], true, 0.5)
		AudioManager.mute_layer(parallel_track_name, ["Freeze"], false, 0.5)
		music_zone = "Freeze"

func _on_desert_body_entered(body):
	if body.is_in_group("Player"):
		AudioManager.mute_layer(parallel_track_name, [], true, 0.5)
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
	with_bus_volume(-10.0)

func _on_area_2d_body_exited(_body):
	## With Bus Volume
	with_bus_volume(0.0)
	

func with_bus_volume(target_volume):
	var vol = AudioManager.get_track_bus_volume_db()
	var index = AudioManager.get_track_bus_index()
	if AudioManager.current_playback != null:
		var tween = create_tween()
		tween.tween_method(AudioManager.set_bus_volume_db.bind(index), vol, target_volume, 1.5)



## -------------------------------------------------------------------------------------------------
## Change Scene ##s
func _on_exit_body_entered(body):
	if body.is_in_group("Player"):
		get_tree().call_deferred("change_scene_to_file", 
		"res://addons/AdaptiSound/DEMO/Scenes/AdaptiveScene.tscn")
