extends Node

const ADAPTIVE_TRACKS = preload("res://addons/AudioManager/Singleton/AdaptiveMusic.gd")
const DEBUG = preload("res://addons/AudioManager/Singleton/DEBUG.gd")
const TOOLS = preload("res://addons/AudioManager/Singleton/Tools.gd")
const AUDIO = preload("res://addons/AudioManager/Nodes/ParallelTrack/Audio_Stream.tscn")

## Choose the extension of audio files
@export var audio_extensions : Array[String]

## Music directories to load. [br][b]This is for Background Music (BGM)[/b]
@export_dir var music_paths

## Adaptive Music directories to load. [br][b]This is for Adaptive Background Music (ABGM)[/b]
@export_dir var adaptive_music_paths

## Sound directories to load [br][b]This is for Background Sounds (BGS)[/b]
@export_dir var sound_paths

## SET PLUGIN DEBUG.console
@export var debugging = false

@onready var bgm_container = get_node("Background_Music")
@onready var bgs_container = get_node("Background_Sounds")
@onready var abgm_container = get_node("Adaptive_BGM")

var debug = DEBUG.new()
var files_tools = TOOLS.new()
var ABGM = ADAPTIVE_TRACKS.new()

# Arrays de sonidos precargados
var background_sounds = {}
var background_music = {}
var adaptive_bgm = {}

var bgs_current_playback

func _ready():
	background_sounds = files_tools.files_load(sound_paths, audio_extensions)
	background_music = files_tools.files_load(music_paths, audio_extensions)
	adaptive_bgm = files_tools.preload_adaptive_tracks(adaptive_music_paths)



######################
## Playback Options ##
######################

func play_music(sound_name : String, volume_db := 0.0, loop := false,
	fade_time = 0.0, pitch_scale := 1):
		
	var audio_stream = add_track(sound_name)
	
	if audio_stream != null:
		
		if audio_stream.playing:
			debug._print("DEBUG: " + sound_name + " already playing")
			return
		
		audio_stream.pitch_scale = pitch_scale
		audio_stream.volume_db = volume_db
		audio_stream.can_loop = loop
		
		if fade_time != 0.0:
			audio_stream.volume_db = -50.0
		audio_stream.on_fade_in(volume_db, fade_time)
		audio_stream.play()
		
		bgs_current_playback = audio_stream


func reset(sound_name : String):
	var audio_stream
	if get_audio_track(sound_name, "bgm") != null:
		audio_stream = get_audio_track(sound_name, "bgm")
	else:
		audio_stream = get_audio_track(sound_name, "bgs")
	if audio_stream != null:
		audio_stream.play()
		return
	else:
		debug._print("DEBUG: " + sound_name + " not found to reset")


func change_bgs(from_track : String, to_track : String, loop := false,
	fade_out := 1.5, fade_in := 0.5, volume_db := 0.0):
	
	var old_track = get_audio_track(from_track, "bgs")
	if old_track == null:
		debug._print("DEBUG: from_track not found")
		return
		
	var audio_stream
	audio_stream = add_track(to_track)
	
	if audio_stream.playing:
		debug._print("DEBUG: to_track already playing")
		return
	
	if audio_stream != null:
		fades(old_track, -50.0, fade_out, true)
		audio_stream.on_fade_in(volume_db, fade_in)
		
		audio_stream.play()
		
		bgs_current_playback = audio_stream
	

func stop_music(sound_name : String, fade_time := 1.5):
	var audio_stream
	if get_audio_track(sound_name, "bgm") != null:
		audio_stream = get_audio_track(sound_name, "bgm")
	else:
		audio_stream = get_audio_track(sound_name, "bgs")
	
	if audio_stream != null:
		fades(audio_stream, -50.0, fade_time, true)
		bgs_current_playback = null
	else:
		debug._print("DEBUG: " + sound_name + " not found to stop")


func stop_all(type := "all", fade_time := 1.5, can_destroy := true):
	var types = [bgm_container, abgm_container, bgs_container]
	
	if type == "bgm":
		var childs = bgm_container.get_children()
		for i in childs:
			fades(i, -50.0, fade_time, can_destroy)
	elif type == "abgm":
		var childs = abgm_container.get_children()
		for i in childs:
			fades(i, -50.0, fade_time, can_destroy)
	elif type == "bgs":
		var childs = bgs_container.get_children()
		for i in childs:
			fades(i, -50.0, fade_time, can_destroy)
	else:
		for i in types:
			for n in i.get_children():
				fades(n, -50.0, fade_time, can_destroy)
	
	bgs_current_playback = null
	
	debug._print("DEBUG: All audios destroyed")



	###########
	## TOOLS ##
	###########
	
func add_track(sound_name : String):
	var container = get_audio_preload(sound_name)
	
	if container == null:
		debug._print("DEBUG: Track not found")
		return
		
	if container == bgm_container:
		var track = get_audio_track(sound_name, "bgm")
		if track != null:
			return track
		else:
			return add_bgm_track(sound_name, container)
			
	if container == bgs_container:
		var track = get_audio_track(sound_name, "bgs")
		if track != null:
			return track
		else:
			return add_bgs_track(sound_name, container)

func add_bgm_track(sound_name : String, container):
	var audio_stream = AUDIO.instantiate()
	bgm_container.add_child(audio_stream)
	audio_stream.stream = background_music[sound_name]
	audio_stream.name = sound_name
	return audio_stream
	
	
func add_bgs_track(sound_name : String, container):
	var audio_stream = AUDIO.instantiate()
	bgs_container.add_child(audio_stream)
	audio_stream.stream = background_sounds[sound_name]
	audio_stream.name = sound_name
	return audio_stream
	

func fades(object, value, fade_time, destroy := false):
	var tween = create_tween()
	tween.tween_property(object, "volume_db", value, fade_time)
	if destroy:
		tween.tween_callback(destroy_audiostream.bind(object))


func destroy_audiostream(track):
	if track != null:
		if track.is_class("AudioStreamPlayer"):
			track.stop()
		track.queue_free()



	#########################
	## SETTERS AND GETTERS ##
	#########################
	
func get_audio_preload(sound_name : String):
	if background_music.has(sound_name):
		return bgm_container
	elif background_sounds.has(sound_name):
		return bgs_container
	else:
		return null


func get_audio_track(sound_name : String, type : String):
	if type == "bgm":
		for i in bgm_container.get_children():
			if i.name == sound_name:
				return i
				
	if type == "abgm":
		for i in abgm_container.get_children():
			if i.name == sound_name:
				return i
	
	if type == "bgs":
		for i in bgs_container.get_children():
			if i.name == sound_name:
				return i
