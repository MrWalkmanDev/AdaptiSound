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

## PANELS ##
const MainPanel = preload("res://addons/AdaptiSound/Panel/MainPanel.tscn")
const INSPECTOR = preload("res://addons/AdaptiSound/EditorInspector/InspectorPlugin.gd")
const BEAT_EDITOR_PANEL = preload("res://addons/AdaptiSound/EditorInspector/InteractivePlayer/BeatSystemEditor.tscn")

var beat_panel
var main_instance
var inspector_plugin

var editor_selection = get_editor_interface().get_selection()


func _enter_tree():
	## Add Singleton ##
	add_autoload_singleton("AudioManager", "res://addons/AdaptiSound/Singleton/AudioManager.tscn")

	## Add nodes ##
	add_custom_type("AudioInteractivePlaylist", "Node", interactive_player, interactive_icon)
	#add_custom_type("AudioCombined", "Node", adaptitrack, adaptive_track_icon)
	add_custom_type("AudioSynchronized", "Node", synchronized_player, parallel_track_icon)
	
	## Inspector Plugin ##
	inspector_plugin = INSPECTOR.new()
	add_inspector_plugin(inspector_plugin)
	
	editor_selection.connect("selection_changed", _on_selection_changed)
	beat_panel = BEAT_EDITOR_PANEL.instantiate()
	
	## MAIN PANEL ##
	main_instance = MainPanel.instantiate()
	add_control_to_dock(DOCK_SLOT_RIGHT_UL, main_instance)
	
func _exit_tree():
	remove_autoload_singleton("AudioManager")
	#remove_custom_type("AudioCombined")
	remove_custom_type("AudioSynchronized")
	remove_custom_type("AudioInteractivePlaylist")
	
	if main_instance:
		remove_control_from_bottom_panel(beat_panel)
		beat_panel.queue_free()
		remove_inspector_plugin(inspector_plugin)
		remove_control_from_docks(main_instance)
		main_instance.queue_free()


func _on_selection_changed():
	var selected = editor_selection.get_selected_nodes()
	if not selected.is_empty():
		# Always pick first node in selection
		var selected_node = selected[0]
		if selected_node is AdaptiNode:
			remove_control_from_bottom_panel(beat_panel)
			add_control_to_bottom_panel(beat_panel, "Audio Editor Preview")
			beat_panel.initialize_panel(selected_node)
			#_make_visible(false)
		else:
			remove_control_from_bottom_panel(beat_panel)
			#_make_visible(false)
	else:
		remove_control_from_bottom_panel(beat_panel)
		#_make_visible(false)


func _make_visible(value : bool):
	if beat_panel:
		beat_panel.visible = value
		#
#func _get_plugin_name():
	#return "AdaptiSound"
	
#func _get_plugin_icon():
	#return dock_icon #get_editor_interface().get_base_control().get_theme_icon("AudioStreamPlayer", "EditorIcons")
