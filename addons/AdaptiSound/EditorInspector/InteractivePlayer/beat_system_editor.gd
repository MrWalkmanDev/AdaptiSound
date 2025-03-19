@tool
extends Control

@onready var clip_slots_container = %ClipSlots
@onready var initial_clip : OptionButton = %InitialClip
## Settings Buttons ##
@onready var volume_slider : HSlider = %Volume
@onready var volume_spin : SpinBox = %VolValue
@onready var pitch_slider : HSlider = %Pitch
@onready var pitch_spin : SpinBox = %PitchValue
@onready var fade_in : HSlider = %FadeIn
@onready var fade_in_value : SpinBox = %FadeInValue
@onready var fade_out : HSlider = %FadeOut
@onready var fade_out_value = %FadeOutValue

var node_selected : AdaptiNode
var layer_methods = AdaptiLayerPreviewMethods.new()
var clip_methods = AdaptiClipPreviewMethods.new()

func initialize_panel(selection:AdaptiNode):
	set_process(true)
	node_selected = selection
	
	if node_selected is AudioInteractivePlayer:
		%AudioSynchOption.visible = false
		%ShuffleMode.visible = true
		%Fades.visible = true
		%InitialClipContainer.visible = true
		
		clip_methods.node_selected = node_selected
		clip_methods.clip_slots_container = clip_slots_container
		clip_methods.initial_clip = initial_clip
		clip_methods.volume_slider = volume_slider
		clip_methods.volume_spin = volume_spin
		clip_methods.pitch_slider = pitch_slider
		clip_methods.pitch_spin = pitch_spin
		clip_methods.fade_in = fade_in
		clip_methods.fade_in_value = fade_in_value
		clip_methods.fade_out = fade_out
		clip_methods.fade_out_value = fade_out_value
		clip_methods.initialize_panel()
		
	elif node_selected is AudioSynchronizedPlayer:
		%AudioSynchOption.visible = true
		%ShuffleMode.visible = false
		%Fades.visible = false
		%InitialClipContainer.visible = false
		
		%BPM.value = node_selected.beat_system.bpm
		%Mesaure.value = node_selected.beat_system.beats_per_bar
		%FadeTime.value = node_selected.fade_time
		
		layer_methods.node_selected = node_selected
		layer_methods.layer_slots_container = clip_slots_container
		layer_methods.volume_slider = volume_slider
		layer_methods.volume_spin = volume_spin
		layer_methods.pitch_slider = pitch_slider
		layer_methods.pitch_spin = pitch_spin
		layer_methods.fade_time = fade_in
		layer_methods.fade_time_value = fade_in_value
		layer_methods.initialize_panel()


func update_clips():
	if node_selected is AudioInteractivePlayer:
		clip_methods.update_clips()


func update_bars():
	if node_selected is AudioInteractivePlayer:
		clip_methods.update_bars()
		
		
func _process(delta: float) -> void:
	if visible:
		update_bars()
		set_process(false)


## -------------------------------------------------------------------------------------------
## PLAYBACK BUTTONS ##
func _on_suffle_mode_toggled(toggled_on: bool) -> void:
	if node_selected is AudioInteractivePlayer:
		clip_methods._on_suffle_mode_toggled(toggled_on)

func _on_initial_clip_item_selected(index: int) -> void:
	if node_selected is AudioInteractivePlayer:
		clip_methods._on_initial_clip_item_selected(index)

func _on_play_from_zero_pressed() -> void:
	if node_selected is AudioInteractivePlayer:
		clip_methods._on_play_from_zero_pressed()
	else:
		layer_methods._on_play_from_zero_pressed()

func _on_play_pressed(clip_slot:AdaptiClipSlot):
	if node_selected is AudioInteractivePlayer:
		clip_methods._on_play_pressed(clip_slot)

func _on_stop_pressed() -> void:
	if node_selected is AudioInteractivePlayer:
		clip_methods._on_stop_pressed()
	else:
		layer_methods._on_stop_pressed()
	
func _on_pause_pressed() -> void:
	if node_selected is AudioInteractivePlayer:
		clip_methods._on_pause_pressed()
	else:
		layer_methods._on_pause_pressed()

## -------------------------------------------------------------------------------------------
## NAVIGATION METHODS ##
func _on_update_pressed() -> void:
	if node_selected is AudioInteractivePlayer:
		clip_methods._on_update_pressed()
	else:
		layer_methods._on_update_pressed()


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
	if node_selected is AudioInteractivePlayer:
		node_selected.fade_in_time = value

func _on_fade_in_value_value_changed(value: float) -> void:
	fade_in.value = value

func _on_fade_out_value_changed(value: float) -> void:
	fade_out_value.value = value
	if node_selected is AudioInteractivePlayer:
		node_selected.fade_out_time = value

func _on_fade_out_value_value_changed(value: float) -> void:
	fade_out.value = value
	
## AudioSynchronizedPlayer ##
func _on_fade_time_value_changed(value: float) -> void:
	%FadeTimeValue.value = value
	if node_selected is AudioSynchronizedPlayer:
		node_selected.fade_time = value

func _on_fade_time_value_value_changed(value: float) -> void:
	%FadeTime.value = value
	
func _on_bpm_value_changed(value: float) -> void:
	if node_selected is AudioSynchronizedPlayer:
		node_selected.beat_system.bpm = value

func _on_mesaure_value_changed(value: float) -> void:
	if node_selected is AudioSynchronizedPlayer:
		node_selected.beat_system.beats_per_bar = value


## Clips Array Methods ##
func _on_add_clip_pressed() -> void:
	if node_selected is AudioInteractivePlayer:
		clip_methods._on_add_clip_pressed()
	else:
		layer_methods._on_add_clip_pressed()

func clips_array_changed() -> void:
	_on_update_pressed()



## -------------------------------------------------------------------------------------------------
## DEBUG ##
func _print(message:String):
	print("AudioEditorPreview: " + str(message))
