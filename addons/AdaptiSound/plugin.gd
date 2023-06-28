@tool
extends EditorPlugin

const dock_icon = preload("res://addons/AdaptiSound/Icons/Dock.png")
const adaptive_track_icon = preload("res://addons/AdaptiSound/Icons/Adaptive.png") 
const parallel_track_icon = preload("res://addons/AdaptiSound/Icons/Parallel.png")
const layer_track_icon = preload("res://addons/AdaptiSound/Icons/Layer.png")
const secuencetrack_icon = preload("res://addons/AdaptiSound/Icons/Secuencer.png")

const MainPanel := preload("res://addons/AdaptiSound/Panel/MainPanel.tscn")
#signal file_names_updated(file_names)
var main_instance

func _enter_tree():
	# Add Singleton #
	add_autoload_singleton("AudioManager", "res://addons/AdaptiSound/Singleton/AudioManager.tscn")
	
	# Add nodes #
	add_custom_type("AdaptiveTrack", "Node",
	preload("res://addons/AdaptiSound/Nodes/AdaptiveTrack/AdaptiveTrack.gd"), 
	adaptive_track_icon)
	
	add_custom_type("ParallelTrack", "Node",
	preload("res://addons/AdaptiSound/Nodes/ParallelTrack/ParallelTrack.gd"),
	parallel_track_icon)
	
	add_custom_type("ParallelLayer", "Node",
	preload("res://addons/AdaptiSound/Nodes/ParallelTrack/ParallelLayer.gd"),
	layer_track_icon)
	
	add_custom_type("SecuenceTrack", "Node",
	preload("res://addons/AdaptiSound/Nodes/SecuenceTrack/SecuenceTrack.gd"),
	secuencetrack_icon)
	
	main_instance = MainPanel.instantiate()
	main_instance.hide()
	get_editor_interface().get_editor_main_screen().add_child(main_instance)
	#add_control_to_dock(DOCK_SLOT_LEFT_UR, main_instance)
	# Hide Panel
	_make_visible(false)
	
	#get_editor_interface().get_resource_filesystem().connect("filesystem_changed", _on_filesystem_changed)
	
func _exit_tree():
	remove_autoload_singleton("AudioManager")
	remove_custom_type("AdaptiveTrack")
	remove_custom_type("ParallelTrack")
	remove_custom_type("ParallelLayer")
	remove_custom_type("SecuenceTrack")
	
	if main_instance:
		remove_control_from_bottom_panel(main_instance)
		main_instance.queue_free()
		
func _has_main_screen():
	return true

func _make_visible(value : bool):
	if main_instance:
		main_instance.visible = value
		
func _get_plugin_name():
	return "AdaptiSound"
	
func _get_plugin_icon():
	return dock_icon #get_editor_interface().get_base_control().get_theme_icon("AudioStreamPlayer", "EditorIcons")

### FILE SYSTEM ###

"""func get_sound_file_names_from_path_r(path : String) -> PackedStringArray:
	var directory : EditorFileSystemDirectory = get_editor_interface().get_resource_filesystem().get_filesystem_path(path)
	var file_name := get_sound_file_names_from_dir_r(directory)
#	directory.free()
	return file_name


func get_sound_file_names_from_dir_r(directory : EditorFileSystemDirectory) -> PackedStringArray:
	if directory == null:
		return PackedStringArray([])
	var file_name = get_sound_file_names_from_dir(directory)
	for i in range(0, directory.get_subdir_count()):
		var subdir = directory.get_subdir(i)
		if subdir.get_name() != "addons":
			file_name += get_sound_file_names_from_dir_r(directory.get_subdir(i))
	return file_name


func get_sound_file_names_from_dir(directory : EditorFileSystemDirectory) -> PackedStringArray:
	var file_names : PackedStringArray = []
	if directory:
		for i in range(0, directory.get_file_count()):
			var file_name = directory.get_file(i)
			if (file_name.get_extension() == "ogg" or
					file_name.get_extension() == "mp3" or
					file_name.get_extension() == "wav" or
					file_name.get_extension() == "opus"):
				file_name = directory.get_path() + file_name
				file_names.append(file_name)
	return file_names

func check_file_names_from_paths() -> void:
	var file_names = get_sound_file_names_from_path_r("res://")
	main_instance.file_names_updated(file_names)
	#emit_signal("file_names_updated", file_names)

func _on_filesystem_changed() -> void:
	check_file_names_from_paths()

func _on_check_file_names_requested() -> void:
	check_file_names_from_paths()"""
