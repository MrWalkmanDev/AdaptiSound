@tool
extends EditorPlugin

## ICONS ##
const dock_icon = preload("res://addons/AdaptiSound/Icons/Dock.png")
const adaptive_track_icon = preload("res://addons/AdaptiSound/Icons/Adaptive.png") 
const parallel_track_icon = preload("res://addons/AdaptiSound/Icons/Synchronized.png")
const interactive_icon = preload("res://addons/AdaptiSound/Icons/Interactive.png")

## NODES ##
const synchronized_player = preload("res://addons/AdaptiSound/Nodes/AudioSynchronizedPlayer/AudioSynchronizedPlayer.gd")
const interactive_player = preload("res://addons/AdaptiSound/Nodes/AudioInteractivePlayer/AudioInteractivePlayer.gd")
const adaptitrack = preload("res://addons/AdaptiSound/Nodes/AdaptiTrack/AdaptiTrack.gd")

## PANELS ##
const MainPanel := preload("res://addons/AdaptiSound/Panel/MainPanel.tscn")
const INSPECTOR = preload("res://addons/AdaptiSound/EditorInspector/InspectorPlugin.gd")

#var audio_tool
var main_instance
var inspector_plugin

func _enter_tree():
	# Add Singleton #
	add_autoload_singleton("AudioManager", "res://addons/AdaptiSound/Singleton/AudioManager.tscn")
	
	# Add nodes #
	add_custom_type("AudioInteractivePlayer", "Node", interactive_player, interactive_icon)
	
	add_custom_type("AudioCombinedPlayer", "Node", adaptitrack, adaptive_track_icon)
	
	add_custom_type("AudioSynchronizedPlayer", "Node", synchronized_player, parallel_track_icon)
	
	## Inspector Plugin ##
	inspector_plugin = INSPECTOR.new()
	add_inspector_plugin(inspector_plugin)
	#audio_tool = AUDIO_TOOL.instantiate()
	#add_control_to_bottom_panel(audio_tool, "Audio Tool")
	
	## MAIN PANEL ##
	main_instance = MainPanel.instantiate()
	add_control_to_dock(DOCK_SLOT_RIGHT_UL, main_instance)
	
func _exit_tree():
	remove_autoload_singleton("AudioManager")
	remove_custom_type("AudioCombinedPlayer")
	remove_custom_type("AudioSynchronizedPlayer")
	remove_custom_type("AudioInteractivePlayer")
	
	if main_instance:
		#remove_control_from_bottom_panel(audio_tool)
		#audio_tool.queue_free()
		remove_inspector_plugin(inspector_plugin)
		remove_control_from_docks(main_instance)
		main_instance.queue_free()
		
#func _has_main_screen():
	#return true
#
#func _make_visible(value : bool):
	#if main_instance:
		#main_instance.visible = value
		#
#func _get_plugin_name():
	#return "AdaptiSound"
	
#func _get_plugin_icon():
	#return dock_icon #get_editor_interface().get_base_control().get_theme_icon("AudioStreamPlayer", "EditorIcons")
