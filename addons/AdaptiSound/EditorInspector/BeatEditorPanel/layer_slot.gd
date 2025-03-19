@tool
extends BoxContainer
class_name AdaptiLayerSlot

signal mute_pressed(clip_slot, value)
signal remove_pressed(clip_slot)
signal audio_slider_value_changed(value)

@onready var clip_name : LineEdit = %ClipName
@onready var layer : AdaptiResourcePicker = %Clip
@onready var audio_slider : HSlider = %AudioSlider
@onready var clip_time : Label = %LayerTime
@onready var bar_container : Control = %BarContainer
@onready var grid : CheckButton = %Grid
@onready var mute_label : Label = %MuteLabel

var layer_resource : AdaptiLayerResource
var audio_interactive_player : AudioSynchronizedPlayer
var audio_stream : AdaptiAudioStreamPlayer

var beat_duration_in_sec : float = 0.0
var snap_value : float = 0.0

var on_grid : bool = true

func _ready() -> void:
	if Engine.is_editor_hint():
		set_process(true)
		if !layer_resource:
			return
		if layer_resource.clip:
			audio_slider.max_value = layer_resource.clip.get_length()
		%MuteButton.button_pressed = layer_resource.mute
		clip_name.text = layer_resource.layer_name
		layer.edited_resource = layer_resource.clip
		beat_duration_in_sec = 60.0 / audio_interactive_player.beat_system.bpm
		snap_value = beat_duration_in_sec
		grid.button_pressed = on_grid
	else:
		set_process(false)


func _process(delta: float) -> void:
	if !Engine.is_editor_hint():
		return
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


func _on_mute_button_toggled(toggled_on: bool) -> void:
	mute_pressed.emit(self, toggled_on)
	var value = "Off"
	if toggled_on:
		value = "On"
	mute_label.text = "Mute " +  value


## -------------------------------------------------------------------------------------------------
## AudioSlider ##
func _on_audio_slider_drag_started() -> void:
	if on_grid:
		audio_slider.step = snap_value
	else:
		audio_slider.step = 0.0

func _on_audio_slider_drag_ended(value_changed: bool) -> void:
	audio_slider.step = 0.0


## -------------------------------------------------------------------------------------------------
## Layer Settings ##
func _on_clip_name_text_changed(new_text: String) -> void:
	layer_resource.layer_name = new_text

func _on_clip_resource_changed(resource: Resource) -> void:
	layer_resource.clip = resource
	
func _on_audio_slider_value_changed(value: float) -> void:
	audio_slider_value_changed.emit(value)


## -------------------------------------------------------------------------------------------------
## Bottom Buttons
func _on_erase_pressed() -> void:
	remove_pressed.emit(self)

func _on_grid_toggled(toggled_on: bool) -> void:
	on_grid = toggled_on

func _on_snap_value_value_changed(value: float) -> void:
	snap_value = 60.0 / (audio_interactive_player.beat_system.bpm * value)
