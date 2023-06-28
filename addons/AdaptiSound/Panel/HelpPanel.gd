@tool
extends Panel

const TOOLS = preload("res://addons/AdaptiSound/Singleton/Tools.gd")

@onready var main = get_parent().get_parent().get_parent()
@onready var label = $Help_Label

var file_browser = TOOLS.new()


func _on_bgm_help_pressed():
	label.text = str(file_browser.files_load(main.line_edit_1.text, main.extensions))
	#label.text = "Aqui debes colocar la ruta de la carpeta que contiene toda la música de background"

func _on_abgm_help_pressed():
	var str = ""
	var dic = file_browser.preload_adaptive_tracks(main.line_edit_0.text)
	for i in dic:
		str += str(i) + ": " + str(dic[i]) + "\n"
	var audios = str
	label.text = audios
