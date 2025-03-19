@tool
extends Resource
class_name AdaptiClipPreviewMethods

const CLIP_SLOT = preload("res://addons/AdaptiSound/EditorInspector/BeatEditorPanel/clip_slot.tscn")

var clip_slots_container : VBoxContainer
var initial_clip : OptionButton
## Settings Buttons ##
var volume_slider : HSlider
var volume_spin : SpinBox
var pitch_slider : HSlider
var pitch_spin : SpinBox
var fade_in : HSlider
var fade_in_value : SpinBox
var fade_out : HSlider
var fade_out_value : SpinBox

var clips_slots : Array[AdaptiClipSlot] = []

var node_selected : AudioInteractivePlayer
var audio_stream : AudioStreamPlayer
var current_clip_slot : AdaptiClipSlot

func initialize_panel():
	current_clip_slot = null
	audio_stream = null
	clip_slots_container.visible = true
	
	if !node_selected.ClipChanged.is_connected(clip_changed):
		node_selected.ClipChanged.connect(clip_changed)
	if !node_selected.clips_array_changed.is_connected(clips_array_changed):
		node_selected.clips_array_changed.connect(clips_array_changed)
		
	fade_in.value = node_selected.fade_in_time
	fade_out.value = node_selected.fade_out_time
	volume_slider.value = node_selected.volume_db
	pitch_slider.value = node_selected.pitch_scale
	update_clips()

func clip_changed(clip_res : AdaptiClipResource):
	## Reset last clip playing ##
	if current_clip_slot:
		current_clip_slot.audio_slider.value = 0.0
		current_clip_slot.travel_label.visible = false
	## Set new Clip Slot ##
	audio_stream = node_selected.get_audio_stream_player(clip_res.clip_name)
	for i in clips_slots:
		if i.clip_resource == clip_res:
			current_clip_slot = i
			current_clip_slot.audio_slider.max_value = current_clip_slot.clip_resource.clip.get_length()
			current_clip_slot.travel_label.visible = false
			break
	
func _on_update_pressed() -> void:
	if node_selected.playing:
		printerr("Unable to update Audio Editor Preview while a track is playing")
		return
	for i in clips_slots:
		i._ready()
	node_selected.notify_property_list_changed()
	node_selected._enter_tree()
	update_clips()
	update_bars()
	
func update_clips():
	for i in clip_slots_container.get_children():
		i.queue_free()
	clips_slots.clear()
	initial_clip.clear()
	if node_selected.clips.size() == 0:
		return
	for i : AdaptiClipResource in node_selected.clips:
		if i.clip_name:
			
			initial_clip.add_item(i.clip_name)
			
			var clip_slot = CLIP_SLOT.instantiate()
			clip_slot.clip_resource = i
			clip_slot.name = i.clip_name
			clip_slot.audio_stream = node_selected.get_audio_stream_player(i.clip_name)
			clip_slot.audio_interactive_player = node_selected
			
			clip_slot.play_pressed.connect(_on_play_pressed)
			clip_slot.remove_pressed.connect(on_remove_clip_pressed)
			
			clip_slots_container.add_child(clip_slot)
			clips_slots.append(clip_slot)
		else:
			printerr("An unnamed clip has been found")
	
	var initial_clip_idx = 0
	for i in initial_clip.item_count:
		if initial_clip.get_item_text(i) == node_selected.initial_clip:
			initial_clip_idx = i
			break
	initial_clip.select(initial_clip_idx)
	node_selected.initial_clip = initial_clip.get_item_text(initial_clip_idx)


func update_bars():
	for clip_slot : AdaptiClipSlot in clips_slots:
		clip_slot.update_bars()


## Clips Array Methods ##
func _on_add_clip_pressed() -> void:
	var arr = node_selected.clips
	arr.append(null)
	node_selected.set_custom_res(arr)
	_on_update_pressed()
		
func on_remove_clip_pressed(slot:AdaptiClipSlot) -> void:
	var idx = node_selected.clips.find(slot.clip_resource)
	node_selected.clips.erase(slot.clip_resource)
	_on_update_pressed()
			
func clips_array_changed() -> void:
	_on_update_pressed()
	
	
	
## -------------------------------------------------------------------------------------------
## PLAYBACK BUTTONS ##
func _on_suffle_mode_toggled(toggled_on: bool) -> void:
	node_selected.shuffle_playback = toggled_on
	_on_update_pressed()

func _on_initial_clip_item_selected(index: int) -> void:
	node_selected.initial_clip = initial_clip.get_item_text(index)

func _on_play_from_zero_pressed() -> void:
	var clip_name = node_selected.initial_clip
	var clip_slot = null
	for i in clips_slots:
		if i.clip_resource.clip_name == clip_name:
			clip_slot = i
			break
	if !clip_slot:
		printerr("AudioEditor: Clip name not found")
		return
	clip_slot.audio_slider.max_value = clip_slot.clip_resource.clip.get_length()
	audio_stream = node_selected.get_audio_stream_player(clip_name)
	node_selected.play_from_editor(clip_name)
	
func _on_play_pressed(clip_slot:AdaptiClipSlot):
	var clip_name = clip_slot.clip_resource.clip_name
	clip_slot.audio_slider.max_value = clip_slot.clip_resource.clip.get_length()
	
	## Reset last clip playing ##
	if current_clip_slot:
		current_clip_slot.audio_slider.value = 0.0
	
	## Play new clip ##
	audio_stream = node_selected.get_audio_stream_player(clip_name)
	if audio_stream:
		if clip_slot.audio_slider.value != 0.0 and current_clip_slot == null:
			node_selected.beat_editor_play(clip_name, 
			clip_slot.audio_slider.value - \
			AudioServer.get_time_since_last_mix() - \
			AudioServer.get_output_latency())
			current_clip_slot = clip_slot
		else:
			if current_clip_slot:
				if !current_clip_slot.clip_resource.can_be_interrupted:
					print("Clip cannot be interrupted")
					return
				if current_clip_slot.clip_resource.key_bars.size() != 0:
					if clip_slot.clip_resource == current_clip_slot.clip_resource:
						return
					node_selected.key_change_active = true
					node_selected.next_clip_res = clip_slot.clip_resource
					clip_slot.travel_label.visible = true
				else:
					node_selected.play_from_editor(clip_name, 
					volume_slider.value, fade_in.value, fade_out.value)
					current_clip_slot = clip_slot
			else:
				node_selected.play_from_editor(clip_name,
				volume_slider.value, fade_in.value, fade_out.value)
				current_clip_slot = clip_slot

func _on_stop_pressed() -> void:
	node_selected.stop()
	current_clip_slot = null
	for i in clips_slots:
		i.travel_label.visible = false
		i.audio_slider.value = 0.0
	
func _on_pause_pressed() -> void:
	node_selected.stop()
	current_clip_slot = null
