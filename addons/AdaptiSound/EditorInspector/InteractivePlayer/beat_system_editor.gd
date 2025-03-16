@tool
extends Control

const BEAT_BAR = preload("res://addons/AdaptiSound/EditorInspector/BeatEditorPanel/beat_bar.tscn")
const CLIP_SLOT = preload("res://addons/AdaptiSound/EditorInspector/BeatEditorPanel/clip_slot.tscn")

@onready var clip_slots_container = %ClipSlots
## Settings Buttons ##
@onready var volume_slider : HSlider = %Volume
@onready var volume_spin : SpinBox = %VolValue
@onready var pitch_slider : HSlider = %Pitch
@onready var pitch_spin : SpinBox = %PitchValue
@onready var fade_in : HSlider = %FadeIn
@onready var fade_in_value : SpinBox = %FadeInValue
@onready var fade_out : HSlider = %FadeOut
@onready var fade_out_value = %FadeOutValue

var clips_slots : Array[AdaptiClipSlot] = []

var node_selected : AdaptiNode
var audio_stream : AudioStreamPlayer
var current_clip_slot : AdaptiClipSlot

var beat_duration_in_sec : float


func initialize_panel(selection:AdaptiNode):
	set_process(false)
	node_selected = selection
	
	if node_selected is AudioInteractivePlayer:
		current_clip_slot = null
		audio_stream = null
		
		if !node_selected.ClipChanged.is_connected(clip_changed):
			node_selected.ClipChanged.connect(clip_changed)
		fade_in.value = node_selected.time_fade_in
		fade_out.value = node_selected.time_fade_out
		volume_slider.value = node_selected.volume_db
		pitch_slider.value = node_selected.pitch_scale
		update_clips()
		await get_tree().process_frame
		update_bars()
		
	elif node_selected is AudioSynchronizedPlayer:
		return
		#print(node_selected.layers[0].clip.get_length())
		#audio_preview.max_value = node_selected.layers[0].clip.get_length()

func clip_changed(clip_res : AdaptiClipResource):
	## Reset last clip playing ##
	if current_clip_slot:
		current_clip_slot.audio_slider.value = 0.0
	## Set new Clip Slot ##
	audio_stream = node_selected.get_audio_stream_player(clip_res.clip_name)
	for i in clips_slots:
		if i.clip_resource == clip_res:
			current_clip_slot = i
			break
			
	
func update_clips():
	for i in clip_slots_container.get_children():
		i.queue_free()
	clips_slots.clear()
	for i : AdaptiClipResource in node_selected.clips:
		if i.clip_name:
			var clip_slot = CLIP_SLOT.instantiate()
			clip_slot.clip_resource = i
			clip_slot.audio_interactive_player = node_selected
			clip_slot.play_pressed.connect(_on_play_pressed)
			clip_slots_container.add_child(clip_slot)
			clips_slots.append(clip_slot)


func update_bars():
	for clip_slot : AdaptiClipSlot in clips_slots:
		clip_slot.update_bars()
	
		
func _process(delta: float) -> void:
	if audio_stream:
		if audio_stream.playing:
			var song_position = audio_stream.get_playback_position()\
			+ AudioServer.get_time_since_last_mix()
			song_position -= AudioServer.get_output_latency()
			#var song_position_in_beats = int(floor(song_position / beat_duration_in_sec))
			current_clip_slot.audio_slider.value = song_position
				

## -------------------------------------------------------------------------------------------
## PLAYBACK BUTTONS ##
func _on_play_pressed(clip_slot:AdaptiClipSlot):
	var clip_name = clip_slot.clip_resource.clip_name
	clip_slot.audio_slider.max_value = clip_slot.clip_resource.clip.get_length()
	
	## Reset last clip playing ##
	if current_clip_slot:
		current_clip_slot.audio_slider.value = 0.0
	
	## Play new clip ##
	audio_stream = node_selected.get_audio_stream_player(clip_name)
	if audio_stream:
		if clip_slot.audio_slider.value != 0.0:
			node_selected.beat_editor_play(clip_name, 
			clip_slot.audio_slider.value - \
			AudioServer.get_time_since_last_mix() - \
			AudioServer.get_output_latency())
		else:
			node_selected.play(clip_name)
		current_clip_slot = clip_slot
		set_process(true)
	

func _on_stop_pressed() -> void:
	node_selected.stop()
	if current_clip_slot:
		current_clip_slot.audio_slider.value = 0.0
	set_process(false)
	
func _on_pause_pressed() -> void:
	node_selected.stop()
	set_process(false)


## -------------------------------------------------------------------------------------------
## NAVIGATION METHODS ##
func _on_update_pressed() -> void:
	update_bars()

## -------------------------------------------------------------------------------------------
## SETTINGS BUTTONS ##
func _on_volume_value_changed(value: float) -> void:
	volume_spin.value = value
	node_selected.volume_db = value

func _on_vol_value_value_changed(value: float) -> void:
	volume_slider.value = value

func _on_pitch_value_changed(value: float) -> void:
	pitch_spin.value = value
	node_selected.pitch_scale = value

func _on_pitch_value_value_changed(value: float) -> void:
	pitch_slider.value = value

func _on_fade_in_value_changed(value: float) -> void:
	fade_in_value.value = value
	node_selected.time_fade_in = value

func _on_fade_in_value_value_changed(value: float) -> void:
	fade_in.value = value

func _on_fade_out_value_changed(value: float) -> void:
	fade_out_value.value = value
	node_selected.time_fade_out = value

func _on_fade_out_value_value_changed(value: float) -> void:
	fade_out.value = value
