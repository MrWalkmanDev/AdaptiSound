extends Node

const Adaptive_Track = preload("res://addons/AudioManager/Singleton/AdaptiveMusic.gd")

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
var files_tools = Tools.new()
var ABGM = Adaptive_Track.new()

# Arrays de sonidos precargados
var background_sounds = {}
var background_music = {}
var adaptive_bgm = {}

func _input(_event):
	pass
	"""if Input.is_action_just_pressed("ui_up"):
		play_music("Runners")
		var audio = get_audio_stream("Runners")
		audio.set_bus("underwater")
		
	if Input.is_action_just_pressed("ui_down"):
		pass
		
	if Input.is_action_just_pressed("ui_right"):
		var effect = AudioServer.get_bus_effect(1, 0)
		var tween = create_tween()
		tween.tween_property(effect, "cutoff_hz", 800, 2.0)"""

func _ready():
	background_sounds = files_tools.files_load(sound_paths, audio_extensions)
	background_music = files_tools.files_load(music_paths, audio_extensions)
	adaptive_bgm = files_tools.preload_adaptive_tracks(adaptive_music_paths)

# Playback tools #

func play_music(sound_name : String, volume_db := 0.0, loop := false,
	fade_time = 0.0, pitch_scale := 1):
	
	var current_volume_db = -50.0
	var audio_stream
	
	if fade_time != 0.0:
		current_volume_db = -50.0
	else:
		current_volume_db = volume_db
		
	audio_stream = add_audiostream(sound_name, current_volume_db, loop, pitch_scale)
	
	if not audio_stream:
		print("Audio not found, or already playing")
		return
		
	audio_stream.play()
	
	if fade_time != 0.0:
		var tween = create_tween()
		tween.tween_property(audio_stream, "volume_db", volume_db, fade_time)
	
func change_music(from_track : String, to_track : String, loop := false,
	fade_out := 1.5, fade_in := 0.5, volume_db := 0.0):
	
	var old_track = get_audio_track(from_track, "bgm")
	var audio_stream
	audio_stream = add_audiostream(to_track, -50.0, loop)
	
	if not audio_stream:
		print(audio_stream)
		return
		
	audio_stream.play()
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(old_track, "volume_db", -50.0, fade_out)
	tween.tween_property(audio_stream, "volume_db", volume_db, fade_in)
	tween.tween_callback(destroy_audiostream.bind(old_track))

func reset(sound_name : String):
	var music_on = get_audio_track(sound_name, "bgm")
	if music_on != null:
		music_on.play()
		return
	else:
		print("Audio not found to reset")
	
func stop_music(sound_name : String, fade_time := 1.5):
	var audio_stream = get_audio_track(sound_name, "bgm")
	
	if audio_stream != null:
		fades(audio_stream, -50.0, fade_time, true)
	else:
		print("Audio not found to stop")
		
func stop_all(fade_time := 1.5):
	var childs = bgm_container.get_children()
	for i in childs:
		fades(i, -50.0, fade_time, true)
		
		
		
# Tools #

func add_audiostream(sound_name, volume_db, loop, pitch_scale := 1):
	var music_on = get_audio_track(sound_name, "bgm")
	if music_on != null:
		return #"Audio is already playing"
	
	var audio_stream = AudioStreamPlayer.new()
	audio_stream.pitch_scale = pitch_scale
	add_child(audio_stream)
	
	if background_music.has(sound_name):
		audio_stream.stream = background_music[sound_name]

	if not audio_stream.stream:
		return #"Audio not found"
	
	audio_stream.name = sound_name
	audio_stream.volume_db = volume_db
	audio_stream.stream.loop = loop
	
	return audio_stream

func fades(object, value, fade_time, destroy := false):
	var tween = create_tween()
	tween.tween_property(object, "volume_db", value, fade_time)
	if destroy:
		tween.tween_callback(destroy_audiostream.bind(object))

func destroy_audiostream(track):
	if track != null:
		track.stop()
		track.queue_free()

func get_audio_track(sound_name : String, type : String):
	var childs
	if type == "bgm":
		childs = bgm_container.get_children()
	if type == "abgm":
		childs = abgm_container.get_children()
	if type == "bgs":
		childs = bgs_container.get_children()
		
	for i in childs:
		if i.name == sound_name:
			return i
