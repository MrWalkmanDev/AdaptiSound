@tool
extends BoxContainer
class_name AdaptiClipSlot

const BEAT_BAR = preload("res://addons/AdaptiSound/EditorInspector/BeatEditorPanel/beat_bar.tscn")

signal play_pressed(clip_slot)
signal remove_pressed(clip_slot)


@onready var clip_name : LineEdit = %ClipName
@onready var advance_type : OptionButton = %AdvanceType
@onready var clip : AdaptiResourcePicker = %Clip
@onready var bpm : SpinBox = %BPM
@onready var measure : SpinBox = %Measure
@onready var audio_slider : HSlider = %AudioSlider
@onready var clip_time : Label = %ClipTime

@onready var bar_container : Control = %BarContainer
@onready var next_clip : OptionButton = %NextClip

@onready var travel_label : Label = %TravelingLabel

@onready var grid : CheckButton = %Grid

var clip_resource : AdaptiClipResource
var audio_interactive_player : AudioInteractivePlayer
var audio_stream : AdaptiAudioStreamPlayer

var beat_duration_in_sec : float = 0.0
var snap_value : float = 0.0

var on_grid : bool = true

func _ready() -> void:
	if Engine.is_editor_hint():
		set_process(true)
		if audio_interactive_player:
			next_clip.clear()
			var idx = 0
			for i in audio_interactive_player.clips:
				next_clip.add_item(i.clip_name)
				if i.clip_name == clip_resource._next_clip:
					idx = audio_interactive_player.clips.find(i)
			next_clip.select(idx)
			clip_resource._next_clip = next_clip.get_item_text(idx)
		if !clip_resource:
			return
			
		clip_name.text = clip_resource.clip_name
		advance_type.select(clip_resource.advance_type)
		set_advance_type(clip_resource.advance_type)
		clip.edited_resource = clip_resource.clip
		bpm.value = clip_resource.bpm
		measure.value = clip_resource.beats_per_bar
		
		#%TransType.select(clip_resource.entry_transition)
		#_on_trans_type_item_selected(clip_resource.entry_transition)
		#%FadeInValue.value = clip_resource.fade_in_time
		#%FadeOutValue.value = clip_resource.fade_out_time
		
		%Interrupted.button_pressed = clip_resource.can_be_interrupted
		
		beat_duration_in_sec = 60.0 / bpm.value
		snap_value = beat_duration_in_sec
		
		grid.button_pressed = on_grid
	else:
		set_process(false)
		
	
func _process(delta: float) -> void:
	if audio_stream:
		if audio_stream.playing:
			var song_position = audio_stream.get_playback_position()\
			+ AudioServer.get_time_since_last_mix()
			song_position -= AudioServer.get_output_latency()
			#var song_position_in_beats = int(floor(song_position / beat_duration_in_sec))
			audio_slider.value = song_position
			clip_time.text = format_time(song_position)
		else:
			if audio_slider.value == 0.0:
				clip_time.text = "0:00:000"
			else:
				clip_time.text = format_time(audio_slider.value)

func format_time(seconds: float) -> String:
	var minutes = int(seconds) / 60
	var secs = int(seconds) % 60
	var millisecs = int((seconds - int(seconds)) * 1000)
	return "%02d:%02d:%03d" % [minutes, secs, millisecs]
	

func update_bars():
	await get_tree().process_frame
	if !clip_resource.clip:
		print(clip_resource.clip_name + ": audio file not found")
		return
	
	audio_slider.max_value = clip_resource.clip.get_length()
	
	for i in bar_container.get_children():
		i.queue_free()
	beat_duration_in_sec = 60.0 / bpm.value
	var bar_duration = beat_duration_in_sec * measure.value
	var total_bars = clip_resource.clip.get_length() / bar_duration
	var x_size = %BarVisualizer.size.x
	var total_beats = clip_resource.clip.get_length() / beat_duration_in_sec
	
	var distance_beat = x_size / total_beats
	var distance_bar = distance_beat * measure.value
	
	for i in range(ceil(total_bars)):
		var bar = BEAT_BAR.instantiate()
		bar.key_idx = i + 1
		if clip_resource.key_bars.has(i+1):
			bar.button_pressed = true
		bar.global_position.x = (i * distance_bar)
		bar.key_pressed.connect(_on_key_pressed)
		bar_container.add_child(bar)
		
		
func _on_key_pressed(value:bool, key_idx:int):
	if value:
		if !clip_resource.key_bars.has(key_idx):
			clip_resource.key_bars.append(key_idx)
	else:
		if clip_resource.key_bars.has(key_idx):
			clip_resource.key_bars.erase(key_idx)


##------------------------------------------------------------------------------
## Playback ##
func _on_play_pressed() -> void:
	play_pressed.emit(self)


##------------------------------------------------------------------------------
## Clip Settings ##
func _on_clip_name_text_changed(new_text: String) -> void:
	clip_resource.clip_name = new_text
	#name_changed.emit(new_text)

func _on_clip_resource_changed(resource: Resource) -> void:
	clip_resource.clip = resource
	#clip_changed.emit(resource)
	

##------------------------------------------------------------------------------
## Advance Type Methods ##
func _on_advance_type_item_selected(index: int) -> void:
	clip_resource.advance_type = index
	set_advance_type(index)
	
func set_advance_type(index:int):
	if index == 1:
		next_clip.visible = true
		%NextClipLabel.visible = true
	else:
		next_clip.visible = false
		%NextClipLabel.visible = false
	#advance_changed.emit(index)

func _on_next_clip_item_selected(index: int) -> void:
	clip_resource._next_clip = next_clip.get_item_text(index)


##------------------------------------------------------------------------------
## Beat Count System
func _on_bpm_value_changed(value: float) -> void:
	clip_resource.bpm = int(value)
	update_bars()
	#bpm_changed.emit(value)

func _on_measure_value_changed(value: float) -> void:
	clip_resource.beats_per_bar = int(value)
	update_bars()
	#measure_changed.emit(value)


##------------------------------------------------------------------------------
## Mouse Draggin ##
func _on_audio_slider_drag_started() -> void:
	if on_grid:
		audio_slider.step = snap_value
	else:
		audio_slider.step = 0.0
	
func _on_audio_slider_drag_ended(_value_changed: bool) -> void:
	audio_slider.step = 0.0
	
	



##------------------------------------------------------------------------------
## Transition Buttons ##
func _on_trans_type_item_selected(index: int) -> void:
	clip_resource.entry_transition = index
	if index != 1:
		%FadeInC.visible = false
		%FadeOutC.visible = false
	else:
		%FadeInC.visible = true
		%FadeOutC.visible = true
	
	
func _on_fade_in_value_value_changed(value: float) -> void:
	clip_resource.fade_in_time = value
	
func _on_fade_out_value_value_changed(value: float) -> void:
	clip_resource.fade_out_time = value

#func _on_transition_toggled(toggled_on: bool) -> void:
	#%All.visible = toggled_on
	#%None.visible = toggled_on
	#bar_container.visible = toggled_on
	#if toggled_on:
		#update_bars()
	#else:
		#for i in bar_container.get_children():
			#i.button_pressed = false
			
func _on_all_pressed() -> void:
	for i in bar_container.get_children():
		i.button_pressed = true

func _on_none_pressed() -> void:
	for i in bar_container.get_children():
		i.button_pressed = false


##------------------------------------------------------------------------------
## Bottom Options
func _on_erase_pressed() -> void:
	remove_pressed.emit(self)

func _on_grid_toggled(toggled_on: bool) -> void:
	on_grid = toggled_on

func _on_snap_value_value_changed(value: float) -> void:
	snap_value = 60.0 / (bpm.value * value)

func _on_interrupted_toggled(toggled_on: bool) -> void:
	clip_resource.can_be_interrupted = toggled_on
