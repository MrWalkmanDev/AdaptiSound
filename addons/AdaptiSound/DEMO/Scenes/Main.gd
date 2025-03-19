extends Node2D

const ENEMY = preload("res://addons/AdaptiSound/DEMO/Prefabs/skeleton.tscn")

@onready var enemy_container = get_node("Node2D")

var music_zone = "Forest"
var combat = false

var parallel_track_name : String = "example_2"
var combat_track_name : String = "example_1"

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
	## I change the initial track because I don't want an intro.
	AudioManager.create_audio_track(combat_track_name).set_initial_clip("Loop1")
	AudioManager.play_music(combat_track_name, 0.0, 0.7, 1.0)
	
	
	## Switch to the "Loop1" clip just in case the outro is still playing.
	## (As if returning to a battle after having already escaped)
	#AudioManager.remove_callback(combat_track_name)
	AudioManager.change_clip(combat_track_name, "Loop1", 0.7, 1.0)

func off_combat():
	## Set a callback when the "Outro" clip has finished
	AudioManager.set_callback(combat_track_name, back_to_main_theme)
	
	## In this case I don't change can_be_interrupted parameter,
	## because I do want this audio to be able to switch to another clip while it's playing.
	AudioManager.change_clip(combat_track_name, "Outro")
	
func _on_button_pressed():
	var instance = ENEMY.instantiate()
	var spawn_position = $CanvasLayer/Control/Panel.get_viewport().get_canvas_transform()
	instance.position = -spawn_position[2] + $CanvasLayer/Control/Panel.position
	enemy_container.add_child(instance)


func back_to_main_theme():
	AudioManager.play_music(parallel_track_name)
	AudioManager.mute_all_layers(true, 0.0)
	AudioManager.mute_layer(music_zone, false, 1.0)
	

## -------------------------------------------------------------------------------------------------
###################
## PARALLELTRACK ##
###################

var fade_out : float = 1.3
var fade_time : float = 1.0

func _on_forest_body_entered(body):
	if body.is_in_group("Player"):
		AudioManager.mute_all_layers(true, fade_out)
		AudioManager.mute_layer("Forest", false, fade_time)
		music_zone = "Forest"

func _on_ice_body_entered(body):
	if body.is_in_group("Player"):
		AudioManager.mute_all_layers(true, fade_out)
		AudioManager.mute_layer("Freeze", false, fade_time)
		music_zone = "Freeze"

func _on_desert_body_entered(body):
	if body.is_in_group("Player"):
		AudioManager.mute_all_layers(true, fade_out)
		AudioManager.mute_layer("Desert", false, fade_time)
		music_zone = "Desert"

func _on_volvano_body_entered(body):
	if body.is_in_group("Player"):
		AudioManager.mute_all_layers(true, fade_out)
		AudioManager.mute_layer("Volcano", false, fade_time)
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
