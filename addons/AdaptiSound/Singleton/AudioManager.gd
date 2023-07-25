extends Node

const ADAPTIVE_TRACKS = preload("res://addons/AdaptiSound/Singleton/AdaptiveMusic.gd")
const BGS_TRACKS = preload("res://addons/AdaptiSound/Singleton/BGSOptions.gd")
const DEBUG = preload("res://addons/AdaptiSound/Singleton/DEBUG.gd")
const TOOLS = preload("res://addons/AdaptiSound/Singleton/AudioTools.gd")
const FILE_BROWSER = preload("res://addons/AdaptiSound/Singleton/FileBrowser.gd")

## Choose the extension of audio files
var audio_extensions : Array
var bgs_extensions : Array

## Music directories to load. This is for Background Music (BGM)
var music_paths

## Adaptive Music directories to load. This is for Adaptive Background Music (ABGM)
var adaptive_music_paths

## Sound directories to load. This is for Background Sounds (BGS)
var sound_paths

## SET PLUGIN DEBUG.console
@export var debugging = false

@onready var bgm_container = get_node("Background_Music")
@onready var bgs_container = get_node("Background_Sounds")
@onready var abgm_container = get_node("Adaptive_BGM")

var debug = DEBUG.new()
var files_browser = FILE_BROWSER.new()
var ABGM = ADAPTIVE_TRACKS.new()
var BGS = BGS_TRACKS.new()
var tools = TOOLS.new()

## Dictionaries of Music Preloads
var background_sounds = {}
var background_music = {}
var adaptive_bgm = {}

## Current Playback in Scene
var current_playback
var current_bgs_playback

## Buses for audio types
var abgm_bus : String
var bgm_bus : String
var bgs_bus : String



func _ready():
	initialize_manager()
	
	background_music = files_browser.files_load(music_paths, audio_extensions)
	background_sounds = files_browser.files_load(sound_paths, bgs_extensions)
	adaptive_bgm = files_browser.preload_adaptive_tracks(adaptive_music_paths)
	
	if background_music == {}:
		debug._print("DEBUG: BGM no files")
	if background_sounds == {}:
		debug._print("DEBUG: BGS no files")
	if adaptive_bgm == {}:
		debug._print("DEBUG: ABGM no files")

func initialize_manager():
	var data = tools.load_json()
	
	adaptive_music_paths = data.ABGM
	music_paths = data.BGM
	sound_paths = data.BGS
	debugging = data.debbug
	audio_extensions = data.extensions
	bgs_extensions = data.bgs_extensions
	
	abgm_bus = data.abgm_bus
	bgm_bus = data.bgm_bus
	bgs_bus = data.bgs_bus



######################
## Playback Options ##
######################

## Add track without play
func add_track(sound_name : String):
	var track_data = get_track_data(sound_name)
	var audio_stream = tools.add_track(sound_name, track_data)
	return audio_stream
	
## Remove track
func remove_track(track_name : String):
	var audio_stream = get_audio_track(track_name)
	tools.destroy_audiostream(audio_stream)

## Play music or change current playback
func play_music(sound_name: String, fade_in: = 0.5, fade_out:= 1.5,
	skip_intro := false, loop_index := 0):
		
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
		tools.check_fade(current_playback, fade_out, false)
	
	## Play New Track
	#audio_stream.volume_db = volume_db ## Sube el volumen a todas las pistas
	tools.check_fade(audio_stream, fade_in, true, skip_intro, loop_index)
	current_playback = audio_stream
	
	return audio_stream


## Reset current playback from begining
func reset_music(fade_out := 0.0, fade_in := 0.0):
	var track
	if current_playback != null:
		track = current_playback
		if current_playback is AudioStreamPlayer:
			current_playback.stop()
			#current_playback.play()
		else:
			current_playback.on_stop()
			#current_playback.on_play()
		tools.check_fade(track, fade_in, true)
	else:
		debug._print("DEBUG: There is no playback in progress")
	
	current_playback = track
	return track


## Stop current playback
func stop_music(can_fade := false, fade_out := 1.5):
	var track
	if can_fade == false:
		fade_out = 0.0
		
	if current_playback != null:
		track = current_playback
		tools.check_fade(current_playback, fade_out, false)
	
	
	current_playback = null ## Problemas con el Fade out
	return track


## Stop all global sounds (ABGM, BGM and BGS)
func stop_all(type := "ALL", fade_time := 1.5, can_destroy := true):
	var types = [bgm_container, abgm_container, bgs_container]
	
	if type == "BGM":
		var childs = bgm_container.get_children()
		for i in childs:
			tools.fades(i, -50.0, fade_time, can_destroy)
			
		current_playback = null
		
	elif type == "ABGM":
		var childs = abgm_container.get_children()
		for i in childs:
			tools.fades(i, -50.0, fade_time, can_destroy)
			
		current_playback = null
		
	elif type == "BGS":
		var childs = bgs_container.get_children()
		for i in childs:
			tools.fades(i, -50.0, fade_time, can_destroy)
			
		current_bgs_playback = null
		
	else:
		for i in types:
			for n in i.get_children():
				tools.fades(n, -50.0, fade_time, can_destroy)
				
		current_playback = null
		current_bgs_playback = null
		
		debug._print("DEBUG: All audios destroyed")



###########################
## ABGM Playback Options ##
###########################

## AdaptiveTrack Options
func change_loop(sound_name, loop_by_index, can_fade := false,
	fade_out := 1.5, fade_in := 0.5):
		ABGM.change_loop(sound_name, loop_by_index, can_fade, fade_out, fade_in)
		
func to_outro(sound_name : String, can_fade := false, fade_out := 1.5,
	fade_in := 0.5):
		return ABGM.to_outro(sound_name, can_fade, fade_out, fade_in)
		
func set_sequence(method : Callable):
	current_playback.set_sequence(method)
	
func set_destroy(state : bool):
	current_playback.set_destroy(state)


## ParallelTrack Options
func mute_layer(track_name: String, layer_names: Array, mute_state: bool, 
	fade_time := 2.0, loop_target := -1):
	ABGM.mute_layer(track_name, layer_names, mute_state, fade_time, loop_target)
	
func play_layer(track_name: String, layer_names: Array, fade_time := 2.0):
	ABGM.play_layer(track_name, layer_names, fade_time)

func stop_layer(track_name: String, layer_names: Array, fade_time := 2.0):
	ABGM.stop_layer(track_name, layer_names, fade_time)



##########################
## BGS Playback Options ##
##########################

## Play BGS track or change for another one
func play_sound(sound_name: String, fade_in: = 0.5, fade_out:= 1.5):
	BGS.play_sound(sound_name, fade_in, fade_out)

## Stop current BGS track
func stop_sound(can_fade := false, fade_time := 1.5):
	BGS.stop_sound(can_fade, fade_time)
	
## Mute or unmute current BGS track layer
func mute_bgs_layer(track_name: String, layer_names: Array, mute_state: bool, fade_time := 2.0):
	BGS.mute_bgs_layer(track_name, layer_names, mute_state, fade_time)



#########################
## SETTERS AND GETTERS ##
#########################

## Get track info for use on add_track
func get_track_data(sound_name : String):
	var data = {}
	## BGM
	if background_music.has(sound_name):
		data["type"] = "BGM"
		data["container"] = bgm_container
		data["file"] = background_music[sound_name]
		data["bus"] = bgm_bus
		return data
	## BGS
	elif background_sounds.has(sound_name):
		data["type"] = "BGS"
		data["container"] = bgs_container
		data["file"] = background_sounds[sound_name]
		data["bus"] = bgs_bus
		return data
	## ABGM
	elif adaptive_bgm.has(sound_name):
		data["type"] = "ABGM"
		data["container"] = abgm_container
		data["file"] = adaptive_bgm[sound_name]
		data["bus"] = abgm_bus
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
				
	if type == "ABGM":
		for i in abgm_container.get_children():
			if i.name == sound_name:
				return i
	
	if type == "BGS":
		for i in bgs_container.get_children():
			if i.name == sound_name:
				return i



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
