extends Node
## This tool is designed with the objective of implementing global background music and/or sounds. 
## AudioManager will only play a single Background Music (BGM) track,
## and in parallel one of Background Sound (BGS).

## -------------------------------------------------------------------------------------------------

const ADAPTIVE_TRACKS = preload("res://addons/AdaptiSound/Singleton/AdaptiveMethods.gd")
const BGS_TRACKS = preload("res://addons/AdaptiSound/Singleton/BGSMethods.gd")
const DEBUG = preload("res://addons/AdaptiSound/Singleton/DEBUG.gd")
const TOOLS = preload("res://addons/AdaptiSound/Singleton/AudioTools.gd")
const FILE_BROWSER = preload("res://addons/AdaptiSound/Singleton/FileBrowser.gd")
const AUDIOPLAYER = preload("res://addons/AdaptiSound/Nodes/AudioSynchronizedPlayer/Audio_Stream.tscn")

enum{BGM, BGS}

var debug = DEBUG.new()
var files_browser = FILE_BROWSER.new()
var ABGM_methods = ADAPTIVE_TRACKS.new()
var BGS_methods = BGS_TRACKS.new()
var tools = TOOLS.new()


## -------------------------------------------------------------------------------------------------
## Save audio file extensions for preloading in pools
var audio_extensions : Array
var bgs_extensions : Array


## -------------------------------------------------------------------------------------------------
## Music directories to load. This is for Background Music (BGM)
var bgm_preload : bool = false
var music_paths


## -------------------------------------------------------------------------------------------------
## Adaptive Music directories to load. This is for Adaptive Background Music (ABGM)
var abgm_preload : bool = false
var adaptive_music_paths


## -------------------------------------------------------------------------------------------------
## Sound directories to load. This is for Background Sounds (BGS)
var bgs_preload : bool = false
var sound_paths


## -------------------------------------------------------------------------------------------------
## SET PLUGIN DEBUG.console
@export var debugging = false


## -------------------------------------------------------------------------------------------------
## Global Audio Containers
@onready var bgm_container = get_node("Background_Music")
@onready var bgs_container = get_node("Background_Sounds")


## -------------------------------------------------------------------------------------------------
## Dictionaries of Music Preloads
var background_sounds_pool = {}
var background_music_pool = {}


## -------------------------------------------------------------------------------------------------
## Current Playback in Scene
var current_playback
var current_bgs_playback


## -------------------------------------------------------------------------------------------------
## Buses for audio types
var bgm_bus : String
var bgs_bus : String


## -------------------------------------------------------------------------------------------------
## AudioManager Initialization
func _ready():
	set_process(false)
	initialize_manager()
	
	## Preload every audio and assign on dictionaries
	## If your project has many audio files, 
	## it is recommended to disable this method and load the resources dynamically.
	## In the Audio Panel you can enable/disable directory preloads
	if bgm_preload:
		background_music_pool = files_browser.files_load(music_paths, audio_extensions)
	if bgs_preload:
		background_sounds_pool = files_browser.files_load(sound_paths, bgs_extensions)
		
	## Found ABGM Files and merge to background music dic
	if abgm_preload:
		var abgm_dic = files_browser.preload_adaptive_tracks(adaptive_music_paths)
		background_music_pool.merge(abgm_dic)
	
	if background_music_pool == {}:
		debug._print("DEBUG: BGM no files")
	if background_sounds_pool == {}:
		debug._print("DEBUG: BGS no files")
		
		
## Load AdaptiSound Panel Settings on AudioManager
func initialize_manager():
	var data = tools.load_json()
	if data:
		process_mode = data.process_mode
		
		bgm_preload = data.bgm_preload
		abgm_preload = data.abgm_preload
		bgs_preload = data.bgs_preload
		
		adaptive_music_paths = data.ABGM
		music_paths = data.BGM
		sound_paths = data.BGS
		debugging = data.debbug
		audio_extensions = data.extensions
		bgs_extensions = data.bgs_extensions
		
		## Set Preload Buses ##
		bgm_bus = AudioServer.get_bus_name(data.bgm_bus)
		bgs_bus = AudioServer.get_bus_name(data.bgs_bus)
	else:
		debug._print("DEBUG: DATA file not found")



########################
## Audio Load Methods ##
########################
## Methods for dynamically loading audio files into AudioManager pools.
func load_audio_from_stream(stream:AudioStream, sound_name:String, category:=BGM):
	match category:
		BGM:
			background_music_pool[sound_name] = stream
		BGS:
			background_sounds_pool[sound_name] = stream
	
func load_audio_from_packedscene(scene:PackedScene, sound_name:String, category:=BGM):
	match category:
		BGM:
			background_music_pool[sound_name] = scene
		BGS:
			background_sounds_pool[sound_name] = scene
			
func load_audio_from_filepath(path:String, sound_name:String, category:=BGM):
	match category:
		BGM:
			background_music_pool[sound_name] = load(path)
		BGS:
			background_sounds_pool[sound_name] = load(path)
			
func remove_audio_from_pool(sound_name:String) -> void:
	if background_music_pool.has(sound_name):
		background_music_pool.erase(sound_name)
	else:
		debug._print("sound name not found in bgm pool")
	if background_sounds_pool.has(sound_name):
		background_sounds_pool.erase(sound_name)
	else:
		debug._print("sound name not found in bgs pool")
	
	
## -------------------------------------------------------------------------------------------------
## Add a track to the tree without playing
func create_audio_track(sound_name : String):
	var track_data = get_track_data(sound_name)
	if track_data != null:
		var audio_stream = tools.add_track(sound_name, track_data)
		return audio_stream
	else:
		debug._print("Sound name not found in audio pool")
		return null


## -------------------------------------------------------------------------------------------------
## Remove track from tree using queue_free()
func remove_audio_track(track_name : String):
	var audio_stream = get_audio_track(track_name)
	if audio_stream:
		tools.destroy_audiostream(audio_stream)
	else:
		debug._print("Audio Track not exist in tree")


## -------------------------------------------------------------------------------------------------
## Remove all tracks from tree using queue_free()
func remove_all_audio_tracks():
	for i in bgm_container:
		i.queue_free()
	for i in bgs_container:
		i.queue_free()


## -------------------------------------------------------------------------------------------------
#############################
## Global Playback Methods ##
#############################
## These are the global playback methods that will work for both audio categories: BGM and BGS.

## Play music or change current playback
func play_music(sound_name: String, vol_db:= 0.0, fade_in:=0.0, fade_out:=0.0):
		
	## Get data of track
	var track_data = get_track_data(sound_name)
	if track_data == null:
		debug._print("DEBUG: Track name not found")
		return
		
	if track_data.type == "BGS":
		debug._print("DEBUG: Track is BGS, use play_sound func")
		return
	
	## Add Track
	var audio_stream = tools.add_track(sound_name, track_data)
	
	if current_playback == audio_stream:
		debug._print("DEBUG: Track already playing")
		return audio_stream
	
	
	## Stop Current Track
	if current_playback != null:
		tools.check_fade_out(current_playback, fade_out)
	
	## Play New Track
	tools.check_fade_in(audio_stream, vol_db, fade_in)
	current_playback = audio_stream
	
	return audio_stream


## -------------------------------------------------------------------------------------------------
## Reset current playback from begining
func reset_music(vol_db:float=current_playback.volume_db):
	var track
	if current_playback != null:
		track = current_playback
		if current_playback is AudioStreamPlayer:
			current_playback.stop()
			#current_playback.play()
		else:
			current_playback.on_stop(0.0)
			#current_playback.on_play()
		tools.check_fade_in(track, vol_db, 0.0)
	else:
		debug._print("DEBUG: There is no playback in progress")
	
	current_playback = track
	return track


## -------------------------------------------------------------------------------------------------
## Stop current playback
func stop_music(fade_out := 0.0, can_destroy := true):
	var track
	if current_playback != null:
		track = current_playback
		tools.check_fade_out(current_playback, fade_out, can_destroy)
	
	current_playback = null
	return track


## -------------------------------------------------------------------------------------------------
## Stop all global audios (ABGM, BGM and BGS)
## NOTE: When using the stop_all method, all tracks will be queue_free
## unless specified in the second parameter of stop_all method
func stop_all(fade_time := 0.0, can_destroy := true):
	var audio_containers = [bgm_container, bgs_container]
	for container in audio_containers:
		for track in container.get_children():
			tools.fades_out(track, -50.0, fade_time, can_destroy)
			
	current_playback = null
	current_bgs_playback = null
	
	debug._print("DEBUG: All audios stopped")


## -------------------------------------------------------------------------------------------------
########################################
## InteractivePlayer Playback Methods ##
########################################

## Change between clips by index (Int) or name (String)
## It only runs on the current_playback
func change_clip(sound_name:String, clip_by_name_or_index, fade_in:=0.0, fade_out:=0.0)->void:
	ABGM_methods.change_clip(sound_name, clip_by_name_or_index, fade_in, fade_out)
	
## Sets the starting clip for the specified track.
func set_initial_clip(track_name:String, clip_name:String)->AudioInteractivePlayer:
	var track = get_audio_track(track_name)
	if track:
		if track is AudioInteractivePlayer:
			track.set_initial_clip(clip_name)
		else:
			debug._print("AudioManager: Cannot change initial_clip on a node other than AudioInteractivePlaylist.")
	return track

## Sets whether the clip can be interrupted by the change_clip or not
func set_can_be_interrupted(track_name:String, clip_name:String, value:bool)->AudioInteractivePlayer:
	var track = get_audio_track(track_name)
	if track:
		if track is AudioInteractivePlayer:
			track.set_can_be_interrupted(clip_name, value)
		else:
			debug._print("AudioManager: Cannot change can_be_interrupted on a node other than AudioInteractivePlaylist.")
	return track


## -------------------------------------------------------------------------------------------------
#########################################
## SynchronizedPlayer Playback Methods ##
#########################################

## Mute or Unmute diferent layers in the current_playback.
func mute_layer(layer, mute_state: bool, fade_time := 2.0):
	ABGM_methods.mute_layer(current_playback, layer, mute_state, fade_time)

## Mute or Unmute all layers in the current_playback
func mute_all_layers(mute_state: bool, fade_time := 2.0):
	ABGM_methods.mute_all_layers(current_playback, mute_state, fade_time)


## -------------------------------------------------------------------------------------------------
##########################
## BGS Playback Options ##
##########################

## Play BGS track or change for another one
func play_sound(sound_name: String, vol_db:=0.0, fade_in: = 0.5, fade_out:= 1.5):
	return BGS_methods.play_sound(sound_name, vol_db, fade_in, fade_out)

## Stop current BGS track
func stop_sound(fade_time := 0.0):
	BGS_methods.stop_sound(fade_time)
	
## Mute or unmute current BGS track layer
func mute_bgs_layer(layer_name, mute_state: bool, fade_time := 2.0):
	BGS_methods.mute_bgs_layer(current_bgs_playback, layer_name, mute_state, fade_time)

## Mute or Unmute all layers in the current_bgs_playback
func mute_bgs_all_layers(mute_state: bool, fade_time := 2.0):
	ABGM_methods.mute_all_layers(current_bgs_playback, mute_state, fade_time)


## -------------------------------------------------------------------------------------------------
############################
## General Adapti Methods ##
############################

## Set a custom method to execute after specific track stops
## For example, you can pass AudioManager.set_sequence(name, custom_method),
## When track "name" stops, custom_method will be started. 
## In this custom method, you can play another track for example
func set_callback(track_name:String, method:Callable):
	var track = get_audio_track(track_name)
	if track:
		track.set_callback(method)

## removes the callback method on the specific track
func remove_callback(track_name:String):
	var track = get_audio_track(track_name)
	if track:
		track.remove_callback()

## If true, specific track is queue_free once to stopped.
func set_destroy(track_name:String, state:bool):
	var track = get_audio_track(track_name)
	if track != null:
		track.set_destroy(state)


## -------------------------------------------------------------------------------------------------
#########################
## SETTERS AND GETTERS ##
#########################

## Get Audio Pools ##
func get_bgs_pool():
	return background_sounds_pool
func get_bgm_pool():
	return background_music_pool

## Get track info for use on add_track
func get_track_data(sound_name : String):
	var data = {}
	## BGM
	if background_music_pool.has(sound_name):
		data["type"] = "BGM"
		data["container"] = bgm_container
		data["file"] = background_music_pool[sound_name]
		data["bus"] = bgm_bus
		return data
	## BGS
	elif background_sounds_pool.has(sound_name):
		data["type"] = "BGS"
		data["container"] = bgs_container
		data["file"] = background_sounds_pool[sound_name]
		data["bus"] = bgs_bus
		return data
	## No Exist
	else:
		return null

## Get track for any purpose
func get_audio_track(sound_name : String):
	var data = get_track_data(sound_name)
	if data == null:
		debug._print("DEBUG: Track not found")
		return
	var type = data["type"]
	
	if type == "BGM":
		for i in bgm_container.get_children():
			if i.name == sound_name:
				return i
	if type == "BGS":
		for i in bgs_container.get_children():
			if i.name == sound_name:
				return i


## -------------------------------------------------------------------------------------------------
#################
## Audio Buses ##
#################

func add_bus(bus_name : String):
	if AudioServer.get_bus_index(bus_name) != -1:
		debug._print("DEBUG: Bus " + bus_name + " already exist")
		return
	
	var bus_count = AudioServer.get_bus_count()
	AudioServer.add_bus(bus_count)
	AudioServer.set_bus_name(bus_count, bus_name)

func get_track_bus_name(sound_name := "current_music"):
	var track
	if sound_name == "current_music":
		track = current_playback
	else:
		track = get_audio_track(sound_name)
		
	if track == null:
		return
		
	return track.bus
	
func get_track_bus_index(sound_name := "current_music"):
	var track
	if sound_name == "current_music":
		track = current_playback
	else:
		track = get_audio_track(sound_name)
		
	if track == null:
		return
		
	var index = AudioServer.get_bus_index(track.bus)
	return index
	
func get_track_bus_volume_db(sound_name := "current_music"):
	var idx
	var vol
	if sound_name == "current_music":
		if current_playback == null:
			debug._print("DEBUG: Cant get bus volume of null")
			return
		idx = AudioServer.get_bus_index(current_playback.bus)
	else:
		idx = get_track_bus_index(sound_name)
		if idx == null:
			idx = AudioServer.get_bus_index(sound_name)
	
	vol = AudioServer.get_bus_volume_db(idx)
	return vol

func set_bus_volume_db(value : float, bus_index := 0):
	AudioServer.set_bus_volume_db(bus_index, value)
