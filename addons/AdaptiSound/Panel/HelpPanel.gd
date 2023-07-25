@tool
extends Panel

const ICON = preload("res://addons/AdaptiSound/Icons/Others/audio_file.png")
#const paralel_ico = preload("res://addons/AdaptiSound/Icons/Parallel.png")
const adaptive_ico = preload("res://addons/AdaptiSound/Icons/Dock.png")
const TOOLS = preload("res://addons/AdaptiSound/Singleton/FileBrowser.gd")

@onready var main = get_parent().get_parent().get_parent()
@onready var label = $HBoxContainer/RightContaainer/Help_Label
@onready var item_list = $HBoxContainer/ItemList

var file_browser = TOOLS.new()

var default_text : String = "Welcome to AdaptiSound \nRemember Save Changes!"

func _ready():
	if Engine.is_editor_hint():
		label.text = default_text

func _on_bgm_help_pressed():
	var text = "Audio directory for background music.
	All subfolders of this directory are searched.
	Support selected extensions"
	if label.text != text:
		label.text = text
	else:
		label.text = default_text

func _on_abgm_help_pressed():
	var text = "Audio directory for
	adaptive background music.
	All subfolders of this directory are searched.
	abgm support only .tscn files. \n
	Note: Make sure you only have abgm 
	files in the directory 
	(AdaptiveTrack, Paralleltrack 
	and SecuenceTrack)."
	
	if label.text != text:
		label.text = text
	else:
		label.text = default_text
	
func _on_bgs_help_pressed():
	var text = "Audio directory for background sounds.
	All subfolders of this directory are searched.
	Support selected extensions"
	
	if label.text != text:
		label.text = text
	else:
		label.text = default_text

func _on_abgm_files_pressed():
	item_list.clear()
	var dic = file_browser.preload_adaptive_tracks(main.abgm.text)
	if dic != null:
		for i in dic:
			item_list.add_item(i, adaptive_ico)

func _on_bgm_files_pressed():
	item_list.clear()
	var dic = file_browser.files_load(main.bgm.text, main.extensions)
	if dic != null:
		for i in dic:
			item_list.add_item(i, ICON)

func _on_bgs_files_pressed():
	item_list.clear()
	var dic = file_browser.files_load(main.bgs.text, main.bgs_extensions)
	if dic != null:
		for i in dic:
			if dic[i] is PackedScene:
				item_list.add_item(i, adaptive_ico)
			else:
				item_list.add_item(i, ICON)

func _on_item_list_item_selected(index):
	var item_name = item_list.get_item_text(index)
	#var item_file = 
	#label.text = ("File Name: " + item_name + "\n" + "Call Name: " + item_name)
	label.text = ("File Name: " + item_name)
