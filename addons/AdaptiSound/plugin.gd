@tool
extends EditorPlugin

const dock_icon = preload("res://addons/AdaptiSound/Icons/Dock.png")
const adaptive_track_icon = preload("res://addons/AdaptiSound/Icons/Adaptive.png") 
const parallel_track_icon = preload("res://addons/AdaptiSound/Icons/Parallel.png")
const layer_track_icon = preload("res://addons/AdaptiSound/Icons/Layer.png")

const MainPanel := preload("res://addons/AdaptiSound/Panel/MainPanel.tscn")
#signal file_names_updated(file_names)
var main_instance

func _enter_tree():
	# Add Singleton #
	add_autoload_singleton("AudioManager", "res://addons/AdaptiSound/Singleton/AudioManager.tscn")
	
	# Add nodes #
	add_custom_type("AdaptiTrack", "Node",
	preload("res://addons/AdaptiSound/Nodes/AdaptiTrack/AdaptiTrack.gd"), 
	adaptive_track_icon)
	
	add_custom_type("ParallelTrack", "Node",
	preload("res://addons/AdaptiSound/Nodes/ParallelTrack/ParallelTrack.gd"),
	parallel_track_icon)
	
	add_custom_type("ParallelLayer", "Node",
	preload("res://addons/AdaptiSound/Nodes/ParallelTrack/ParallelLayer.gd"),
	layer_track_icon)
	
	main_instance = MainPanel.instantiate()
	main_instance.hide()
	get_editor_interface().get_editor_main_screen().add_child(main_instance)
	#add_control_to_dock(DOCK_SLOT_LEFT_UR, main_instance)
	# Hide Panel
	_make_visible(false)
	
	#get_editor_interface().get_resource_filesystem().connect("filesystem_changed", _on_filesystem_changed)
	
func _exit_tree():
	remove_autoload_singleton("AudioManager")
	remove_custom_type("AdaptiTrack")
	remove_custom_type("ParallelTrack")
	remove_custom_type("ParallelLayer")
	
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
