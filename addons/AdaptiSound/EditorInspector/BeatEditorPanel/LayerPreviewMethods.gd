@tool
extends Resource
class_name AdaptiLayerPreviewMethods

const LAYER_SLOT = preload("res://addons/AdaptiSound/EditorInspector/BeatEditorPanel/layer_slot.tscn")

var layer_slots_container : VBoxContainer
## Settings Buttons ##
var volume_slider : HSlider
var volume_spin : SpinBox
var pitch_slider : HSlider
var pitch_spin : SpinBox
var fade_time : HSlider
var fade_time_value : SpinBox

var audio_stream : AudioStreamPlayer
#var current_clip_slot : AdaptiClipSlot

var layer_slots : Array[AdaptiLayerSlot] = []
var node_selected : AudioSynchronizedPlayer = null

func initialize_panel():
	audio_stream = null
	layer_slots_container.visible = true
	
	if !node_selected.layers_array_changed.is_connected(layers_array_changed):
		node_selected.layers_array_changed.connect(layers_array_changed)
		
	fade_time.value = node_selected.fade_time
	fade_time_value.value = node_selected.fade_time
	volume_slider.value = node_selected.volume_db
	pitch_slider.value = node_selected.pitch_scale
	update_slots()

func update_slots():

	for i in layer_slots_container.get_children():
		i.queue_free()
	layer_slots.clear()
	if node_selected.layers.size() == 0:
		return
	for i : AdaptiLayerResource in node_selected.layers:
		if i.layer_name:
			var layer_slot = LAYER_SLOT.instantiate()
			layer_slot.layer_resource = i
			layer_slot.name = i.layer_name
			layer_slot.audio_stream = node_selected.get_audio_stream_player(i.layer_name)
			layer_slot.audio_interactive_player = node_selected
			
			layer_slot.audio_slider_value_changed.connect(slider_value_changed)
			layer_slot.mute_pressed.connect(_on_mute_pressed)
			layer_slot.remove_pressed.connect(on_remove_clip_pressed)
			
			layer_slots_container.add_child(layer_slot)
			layer_slots.append(layer_slot)
		else:
			printerr("An unnamed clip has been found")

	
func _on_update_pressed() -> void:
	if node_selected.playing:
		printerr("Unable to update Audio Editor Preview while a track is playing")
		return
	for i in layer_slots:
		i._ready()
	node_selected.notify_property_list_changed()
	node_selected._enter_tree()
	update_slots()


func update_bars():
	for layer : AdaptiLayerSlot in layer_slots:
		layer.update_bars()


## Clips Array Methods ##
func _on_add_clip_pressed() -> void:
	var arr = node_selected.layers
	arr.append(null)
	node_selected.set_custom_res(arr)
	_on_update_pressed()
		
func on_remove_clip_pressed(slot:AdaptiLayerSlot) -> void:
	var idx = node_selected.layers.find(slot.layer_resource)
	node_selected.layers.erase(slot.layer_resource)
	_on_update_pressed()
			
func layers_array_changed() -> void:
	_on_update_pressed()


## -------------------------------------------------------------------------------------------
## PLAYBACK BUTTONS ##
func slider_value_changed(value:float) -> void:
	for i in layer_slots:
		i.audio_slider.value = value

func _on_play_from_zero_pressed() -> void:
	node_selected.play_from_editor(
		layer_slots[0].audio_slider.value - \
		AudioServer.get_time_since_last_mix() - \
		AudioServer.get_output_latency()
	)

func _on_mute_pressed(slot:AdaptiLayerSlot, value:bool) -> void:
	slot.layer_resource.mute = value
	
func _on_stop_pressed() -> void:
	node_selected.stop()
	for i in layer_slots:
		i.audio_slider.value = 0.0
	
func _on_pause_pressed() -> void:
	node_selected.stop()
