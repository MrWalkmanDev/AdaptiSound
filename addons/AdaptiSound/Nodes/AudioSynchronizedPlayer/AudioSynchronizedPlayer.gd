@tool
extends AdaptiNode
class_name AudioSynchronizedPlayer
## This node allows you to store multiple audio clips that will all play at the same time, 
## creating synchronization between all the clips. [br]
## [b]It has an editor preview[/b], and you can set muted and unmuted layers,
## with a transition time if you want.

## -----------------------------------------------------------------------------
## Beat System Signals
signal BeatChanged(value)
signal BarChanged(value)
signal LoopBegin

## Update Editor Preview ##
signal layers_array_changed

# ------------------------------------------------------------------------------
## Contains the audio clips that will behave as layers of the same synchronized track.
@export var layers : Array[AdaptiLayerResource]: set = set_custom_res


## -----------------------------------------------------------------------------
## PLAYBACK VARIABLES

## If true, the editor can play tracks with the expected behavior.
var editor_preview : bool = true : set = set_on_playing

## Plays the selected clip, also executes the transition between clips.[br]
## Select a different clip than the one currently playing in [b]target_clip[/b], and press this button.
var _play : bool = false : set = set_on_play

## Stops the clip that is playing
var _stop : bool = false:
	set(value):
		stop()
		_stop = false

## Controls the fade-in and fade-out time of layers when muted or unmuted.
var fade_time : float = 1.0

## Dictionary that stores AdaptiAudioStreamPlayer along with their resource data.
var audio_players : Dictionary = {}

## If enabled, the beat counting system will be active, 
## and changes can be synced to other tracks at specific bars.
var beat_system_enable : bool = true :
	set(value):
		beat_system_enable = value
		notify_property_list_changed()

## Beat System Resource
var beat_system : BeatSystemResource

## BEAT SYSTEM ##
func _validate_property(property):
	## BEAT SYSTEM ##
	if property.name == "beat_system" and !beat_system_enable:
		property.usage = PROPERTY_USAGE_NO_EDITOR
		
	if property.name == "_play" and !editor_preview:
		property.usage = PROPERTY_USAGE_NO_EDITOR
		
	if property.name == "_stop" and !editor_preview:
		property.usage = PROPERTY_USAGE_NO_EDITOR
		
	if property.name == "volume_db" and !editor_preview:
		property.usage = PROPERTY_USAGE_NO_EDITOR
		
	if property.name == "pitch_scale" and !editor_preview:
		property.usage = PROPERTY_USAGE_NO_EDITOR
		
	if property.name == "fade_time" and !editor_preview:
		property.usage = PROPERTY_USAGE_NO_EDITOR

func _get_property_list():
	var properties = []
	
	properties.append({
		"name" : "beat_system_enable",
		"type" : TYPE_BOOL,
		"hint" : PROPERTY_HINT_NONE,
	})
	
	properties.append({
		"name" : "beat_system",
		"type" : TYPE_OBJECT,
		"hint" : PROPERTY_HINT_RESOURCE_TYPE,
		"hint_string" : "BeatSystemResource"
	})
	
	## EDITOR TOOL ##
	properties.append({
		"name" : "editor_preview",
		"type" : TYPE_BOOL,
		"hint" : PROPERTY_HINT_NONE
	})
	
	## PLAYBACK PROPERTYS ##
	properties.append({
		"name" : "_play",
		"type" : TYPE_BOOL,
		"hint" : PROPERTY_HINT_NONE
	})
	
	properties.append({
		"name" : "_stop",
		"type" : TYPE_BOOL,
		"hint" : PROPERTY_HINT_NONE
	})
	
	properties.append({
		"name" : "volume_db",
		"type" : TYPE_FLOAT,
		"hint" : PROPERTY_HINT_RANGE,
		"hint_string": "-80.0, 24.0"
	})
	
	properties.append({
		"name" : "pitch_scale",
		"type" : TYPE_FLOAT,
		"hint" : PROPERTY_HINT_RANGE,
		"hint_string": "0.01, 4.0, 1.0",
	})
	
	## FADE ##
	properties.append({
		"name" : "fade_time",
		"type" : TYPE_FLOAT,
		"hint" : PROPERTY_HINT_RANGE,
		"hint_string" : "0.0, 10.0, 0.1"
	})
	
	return properties
	
func _array_to_string(arr:Array[AdaptiLayerResource], separator:=",") -> String:
	var string = ""
	for i in arr:
		string += "Clip " + str(arr.find(i)) + separator
	return string


## -----------------------------------------------------------------------------
var groups = {}


## -----------------------------------------------------------------------------
func _enter_tree():
	create_audio_players()
	if beat_system == null:
		beat_system = BeatSystemResource.new()
	if !beat_system.BeatChanged.is_connected(beat_signal_emit):
		beat_system.BeatChanged.connect(beat_signal_emit)
	if !beat_system.BarChanged.is_connected(bar_signal_emit):
		beat_system.BarChanged.connect(bar_signal_emit)
	if !beat_system.LoopBegin.is_connected(loop_begin_emit):
		beat_system.LoopBegin.connect(loop_begin_emit)
		
	enable_process_mode(false)
	
func enable_process_mode(value:bool):
	if process_callback == 0:
		set_process(value)
		set_physics_process(false)
	else:
		set_physics_process(value)
		set_process(false)
		
## BEAT SYSTEM SIGNALS
func beat_signal_emit(value):
	BeatChanged.emit(value)
func bar_signal_emit(value):
	if beat_system_debug:
		_print("BeatSystem: Measure count: " + str(value))
	BarChanged.emit(value)
func loop_begin_emit():
	if beat_system_debug:
		_print("BeatSystem: Measure count: " + str(1) + " Loop Begin")
	LoopBegin.emit()
	
## -----------------------------------------------------------------------------
func _exit_tree():
	stop()
	
func create_audio_players():
	audio_players.clear()
	for n in get_children():
		n.queue_free()
		
	## Parameters set in Layers
	for i in layers:
		## AudioStream in Layer
		var audio = AudioManager.AUDIOPLAYER.instantiate()
		audio.stream = i.clip
		audio.on_mute = i.mute
		if i.layer_name:
			audio.name = i.layer_name
		audio.set_loop(true)
		
		if !i.is_connected("layer_resource_changed", set_clip_resource):
			i.connect("layer_resource_changed", set_clip_resource)
		if !i.is_connected("mute_layer_changed", set_mute_layer):
			i.connect("mute_layer_changed", set_mute_layer)
		
		## ADD TRACK
		add_child(audio)
		audio_players[i.layer_name] = audio
		#audio.owner = get_tree().edited_scene_root # DEBUG
			
		## Add Groups
		#for n in i.groups:
			#var arr = []
			#if groups.keys().has(n):
				#arr = groups[n]
			#arr.append(i)
			#groups[n] = arr
		
	set_pitch_scale(pitch_scale)
	set_volume_db(volume_db)


## -----------------------------------------------------------------------------
######################
## PLAYBACK METHODS ##
######################

func play_from_editor(song_pos:=0.0, vol_db:=0.0, fade_in:=0.0):
	var childs = get_children()
	if childs.size() == 0:
		_print("No clips in AudioInteractivePlayer")
		return
		
	if playing:
		_print("Clip already playing")
		return
		
	volume_db = vol_db
	if song_pos < 0.0:
		song_pos = 0.0
	
	if song_pos != 0.0:
		for i in get_children():
			if i.on_mute:
				i.on_fade_in(-80.0, 0.0)
			else:
				i.on_fade_in(vol_db, 0.0)
			i.play(song_pos)
	else:
		_play_method(vol_db, fade_in)


func play(vol_db:=0.0, fade_in:=0.0):
	var childs = get_children()
	if childs.size() == 0:
		_print("No clips in AudioInteractivePlayer")
		return
		
	volume_db = vol_db
	if Engine.is_editor_hint() and editor_preview:
		if playing:
			_print("Clip already playing")
			return
		_play_method(vol_db, fade_in)
	else:
		_play_method(vol_db, fade_in)
		
func _play_method(vol_db:=volume_db, fade_time:=0.0):
	for i in get_children():
		if i.on_mute:
			i.on_fade_in(-80.0, fade_time)
		else:
			i.on_fade_in(vol_db, fade_time)
		i.play()

## Stop all tracks
func stop(fade_out_time:=0.0):
	var childs = get_children()
	for i in childs:
		i.on_fade_out(fade_out_time)



## -----------------------------------------------------------------------------
## Playback methods from AudioManager
func on_play(fade_time:=0.0, vol_db:=0.0):
	play(vol_db, fade_time)


func on_stop(fade_time := 0.0, can_destroy := false):
	destroy = can_destroy
	stop(fade_time)


## -----------------------------------------------------------------------------
## Main method to mute and unmute audio layers
func on_mute_layers(layer, mute_state : bool, fade_time:=1.0):
	if typeof(layer) == TYPE_INT:
		if layer > get_child_count() - 1:
			_print("Layer index" + str(layer) + " not found")
		else:
			var node = get_children()[layer]
			if mute_state:
				node.on_fade_out(fade_time, false)
			else:
				node.on_fade_in(volume_db, fade_time)
			node.on_mute = mute_state
				
	else:
		if !audio_players.has(layer):
			_print("Layer name " + layer + " not found")
			return
		#if groups.has(layer):
			#for n in groups[layer]:
				#if mute_state:
					#n.on_fade_out(fade_time, false)
				#else:
					#n.on_fade_in(volume_db, fade_time)
				#n.on_mute = mute_state
		#else:
		var node = audio_players[layer]
		if mute_state:
			node.on_fade_out(fade_time, false)
		else:
			node.on_fade_in(volume_db, fade_time)
		node.on_mute = mute_state

func mute_all_layers(mute_state : bool, fade_time:=1.0):
	for i:AdaptiAudioStreamPlayer in get_children():
		if mute_state:
			i.on_fade_out(fade_time, false)
		else:
			i.on_fade_in(volume_db, fade_time)
		i.on_mute = mute_state

## -----------------------------------------------------------------------------
#################
## BEAT SYSTEM ##
#################
func _process(delta):
	#if process_callback == 0:
	check_track_is_playing()
	if beat_system_enable and audio_players.size() != 0:
		if playing:
			beat_system.beat_process(delta, get_child(0))
		else:
			beat_system.can_first_beat = true
	
func _physics_process(delta):
	#if process_callback == 1:
	check_track_is_playing()
	if beat_system_enable and audio_players.size() != 0:
		if playing:
			beat_system.beat_process(delta, get_child(0))
		else:
			beat_system.can_first_beat = true
			
## -----------------------------------------------------------------------------
#########################
## SETTERS AND GETTERS ##
#########################

func set_on_play(value):
	_play = value
	if _play:
		play(volume_db)
		_play = false
		
func set_volume_db(value : float):
	volume_db = value
	for i:AdaptiAudioStreamPlayer in get_children():
		if !i.on_mute:
			i.volume_db = value
			
func get_audio_stream_player(layer_name:String) -> AdaptiAudioStreamPlayer:
	if audio_players.size() != 0:
		return audio_players[layer_name]
	else:
		return null


## -----------------------------------------------------------------------------
## EDITOR
func set_on_playing(value):
	editor_preview = value
	if !editor_preview:
		stop()
	notify_property_list_changed()


func set_custom_res(value):
	layers.resize(value.size())
	layers = value
	for i in layers.size():
		if not layers[i]:
			layers[i] = AdaptiLayerResource.new()
			layers[i].layer_name = "Layer " + str(i)
			layers[i].resource_name = "Layer " + str(i)
			layers[i].connect("layer_resource_changed", set_clip_resource)
			layers[i].connect("mute_layer_changed", set_mute_layer)
	
	if Engine.is_editor_hint():
		layers_array_changed.emit()
		#create_audio_players()
		notify_property_list_changed()
		
func set_mute_layer(value, res):
	var idx = layers.find(res)
	var track = get_children()[idx]
	on_mute_layers(idx, value, fade_time)

func set_clip_resource(clip, res):
	var idx = layers.find(res)
	var track = get_children()[idx]
	track.stream = clip
	track.set_loop(true)
