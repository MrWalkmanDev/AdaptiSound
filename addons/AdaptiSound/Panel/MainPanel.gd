@tool
extends Control

const SAVE_PATH := "res://addons/AdaptiSound/Panel/Data.json"

@onready var abgm := $Margin/MainH/MainV/Grid/Directories/GridContainer/ABGM
@onready var bgm := $Margin/MainH/MainV/Grid/Directories/GridContainer/BGM
@onready var bgs := $Margin/MainH/MainV/Grid/Directories/GridContainer/BGS
@onready var debbug_button = $Margin/MainH/MainV/Grid/Directories/GridContainer/Debbug

@onready var bgm_bus = $Margin/MainH/MainV/Grid/Extensions/Hbox/Buses/bgmBus
@onready var abgm_bus = $Margin/MainH/MainV/Grid/Extensions/Hbox/Buses/abgmBus
@onready var bgs_bus = $Margin/MainH/MainV/Grid/Extensions/Hbox/Buses/bgsBus

@onready var wav_ext = $Margin/MainH/MainV/Grid/Extensions/Hbox/Extensions/wav
@onready var ogg_ext = $Margin/MainH/MainV/Grid/Extensions/Hbox/Extensions/ogg
@onready var mp3_ext = $Margin/MainH/MainV/Grid/Extensions/Hbox/Extensions/mp3

var debbug : bool = false
var data

# Extensions # 
var extensions = []

func _ready():
	if Engine.is_editor_hint():
		data = load_json()
		abgm.text = data.ABGM
		bgm.text = data.BGM
		bgs.text = data.BGS
		debbug_button.set_pressed(data.debbug)
		debbug = data.debbug
		
		bgm_bus.text = data.bgm_bus
		abgm_bus.text = data.abgm_bus
		bgs_bus.text = data.bgs_bus
		
		set_extension()

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
		"ABGM": abgm.text,
		"BGM": bgm.text,
		"BGS": bgs.text,
		"debbug": debbug,
		"extensions": extensions,
		"abgm_bus": abgm_bus.text,
		"bgm_bus": bgm_bus.text,
		"bgs_bus": bgs_bus.text
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
	else:
		if extensions.has("ogg"):
			extensions.erase("ogg")

func _on_wav_toggled(button_pressed):
	if button_pressed:
		if !extensions.has("wav"):
			extensions.append("wav")
	else:
		if extensions.has("wav"):
			extensions.erase("wav")

func _on_mp_3_toggled(button_pressed):
	if button_pressed:
		if !extensions.has("mp3"):
			extensions.append("mp3")
	else:
		if extensions.has("mp3"):
			extensions.erase("mp3")
