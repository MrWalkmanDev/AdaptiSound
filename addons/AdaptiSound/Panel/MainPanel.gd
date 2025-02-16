@tool
extends Control

const SAVE_PATH := "res://addons/AdaptiSound/Panel/Data.json"

@onready var _process_mode = %ProcessMode

## Directories LineEdits ##
@onready var bgm := %BGM
@onready var abgm := %ABGM
@onready var bgs := %BGS
@onready var debug_button = %Debbug

## Directories Containers and Buttons ##
@onready var bgm_pre :CheckButton= %BGMPre
@onready var bgm_dir_container := %BGMDir
@onready var abgm_dir_container := %ABGMDir
@onready var abgm_pre := %ABGMPre
@onready var bgs_pre := %BGSPre
@onready var bgs_dir_container := %BGSDir

## Buses ##
@onready var bgm_bus = %bgmBus
@onready var bgs_bus = %bgsBus

## Audio Extensions ##
@onready var wav_ext = %wav
@onready var ogg_ext = %ogg
@onready var mp3_ext = %mp3

## DEBUG ##
var debbug : bool = false

## DATA ##
var data

## Extensions ##
var extensions = []
var bgs_extensions = []

func _ready():
	if Engine.is_editor_hint():
		## Adaptive Background Sounds ##
		if !bgs_extensions.has("tscn"):
			bgs_extensions.append("tscn")
			
		## Load Data ##
		data = load_json()
		if !data:
			printerr("AdaptiSound Data not found")
			return
		
		bgm_pre.button_pressed = data.bgm_preload
		abgm_pre.button_pressed = data.abgm_preload
		bgs_pre.button_pressed = data.bgs_preload
		
		bgm.text = data.BGM
		abgm.text = data.ABGM
		bgs.text = data.BGS
		debug_button.set_pressed(data.debbug)
		_process_mode.select(data.process_mode)
		debbug = data.debbug
		
		set_extension()
		
		## AUDIO BUSES ##
		bgm_bus.clear()
		bgs_bus.clear()
		for i in AudioServer.bus_count:
			bgm_bus.add_item(AudioServer.get_bus_name(i), i)
			bgs_bus.add_item(AudioServer.get_bus_name(i), i)
		bgm_bus.selected = data.bgm_bus
		bgs_bus.selected = data.bgs_bus
		
		## Preload Directories ##
		bgs_dir_container.visible = bgs_pre.button_pressed
		bgm_dir_container.visible = bgm_pre.button_pressed
		abgm_dir_container.visible = abgm_pre.button_pressed

func set_extension():
	if data.extensions.has("wav"):
		wav_ext.set_pressed(true)
		_on_wav_toggled(true)
	else: 
		wav_ext.set_pressed(false)
		_on_wav_toggled(false)
		
	if data.extensions.has("ogg"):
		ogg_ext.set_pressed(true)
		_on_ogg_toggled(true)
	else:
		ogg_ext.set_pressed(false)
		_on_ogg_toggled(false)
		
	if data.extensions.has("mp3"):
		mp3_ext.set_pressed(true)
		_on_mp_3_toggled(true)
	else:
		mp3_ext.set_pressed(false)
		_on_mp_3_toggled(false)


func save_json() -> void:
	var data := {
		"abgm_preload" : abgm_pre.button_pressed,
		"bgm_preload" : bgm_pre.button_pressed,
		"bgs_preload" : bgs_pre.button_pressed,
		"ABGM": abgm.text,
		"BGM": bgm.text,
		"BGS": bgs.text,
		"debbug": debbug,
		"process_mode": _process_mode.get_selected_id(),
		"extensions": extensions,
		"bgs_extensions": bgs_extensions,
		"bgm_bus": bgm_bus.get_selected_id(),
		"bgs_bus": bgs_bus.get_selected_id()
	}
	var json_data := JSON.stringify(data)
	var file_access := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file_access.store_line(json_data)
	file_access.close()
	
func load_json():
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file_access := FileAccess.open(SAVE_PATH, FileAccess.READ)
	var json_data := file_access.get_line()
	file_access.close()
	var data: Dictionary = JSON.parse_string(json_data)
	return data

func _on_button_pressed():
	save_json()

func _on_check_button_toggled(button_pressed):
	debbug = button_pressed

func _on_ogg_toggled(button_pressed):
	if button_pressed:
		if !extensions.has("ogg"):
			extensions.append("ogg")
			bgs_extensions.append("ogg")
	else:
		if extensions.has("ogg"):
			extensions.erase("ogg")
			bgs_extensions.erase("ogg")

func _on_wav_toggled(button_pressed):
	if button_pressed:
		if !extensions.has("wav"):
			extensions.append("wav")
			bgs_extensions.append("wav")
	else:
		if extensions.has("wav"):
			extensions.erase("wav")
			bgs_extensions.erase("wav")

func _on_mp_3_toggled(button_pressed):
	if button_pressed:
		if !extensions.has("mp3"):
			extensions.append("mp3")
			bgs_extensions.append("mp3")
	else:
		if extensions.has("mp3"):
			extensions.erase("mp3")
			bgs_extensions.erase("mp3")



## -------------------------------------------------------------------------------------------------
## PRELOAD BUTTONS ##
func _on_bgm_pre_toggled(toggled_on):
	bgm_dir_container.visible = toggled_on

func _on_bgs_pre_toggled(toggled_on):
	bgs_dir_container.visible = toggled_on

func _on_abgm_pre_toggled(toggled_on):
	abgm_dir_container.visible = toggled_on


## -------------------------------------------------------------------------------------------------
## BUSSES ##
func _on_bus_update_pressed():
	bgm_bus.clear()
	for i in AudioServer.bus_count:
		bgm_bus.add_item(AudioServer.get_bus_name(i), i)
	bgm_bus.selected = data.bgm_bus


func _on_sfx_bus_update_pressed():
	bgs_bus.clear()
	for i in AudioServer.bus_count:
		bgs_bus.add_item(AudioServer.get_bus_name(i), i)
	bgs_bus.selected = data.bgs_bus
