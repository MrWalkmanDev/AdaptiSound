@tool
extends AdaptiNode
class_name AudioInteractivePlayer
## This node allows you to store multiple audio clips that can be set to play in
## different ways but only one at a time. [br]
## [b]It has an editor preview[/b], and you can control the fade in and fade out
## times of transitions.


signal ClipChanged(clip_resource:AdaptiClipResource)
signal BarChanged(value)
signal LoopBegin


## Contains the audio clips to be played.
@export var clips : Array[AdaptiClipResource]: set = set_custom_res

## The first clip to play at the start
var initial_clip:String="Clip 0":
	get:
		return initial_clip
	set(value):
		initial_clip = value
		
		
## If true, all tracks are set to random auto-advance
var shuffle_playback : bool = false:
	set(value):
		if value == true:
			for i in clips:
				i.advance_type = 1
		#else:
			#for i in clips:
				#i.advance_type = 0
		shuffle_playback = value


## Clip that will be played once the play button is pressed
#var _editor_target_clip:String="Clip 0":
	#get:
		#return _editor_target_clip
	#set(value):
		#_editor_target_clip = value

## If true, the editor can play tracks with the expected behavior.
var editor_preview : bool = true : set = set_on_playing

## Plays the selected clip, also executes the transition between clips.[br]
## Select a different clip than the one currently playing in [b]target_clip[/b], and press this button.
#var _play : bool = false :
	#set(value):
		#_play = value
		#var childs = get_children()
		#var idx = int(_editor_target_clip)
		#if _play:
			#play(_editor_target_clip, volume_db)
			#_play = false

## Stops the clip that is playing
var _stop : bool = false:
	set(value):
		stop()
		_stop = false

## Fade in time of the clip being played
var time_fade_in : float = 1.0
## Fade time of the clip that stops at the transition
var time_fade_out : float = 1.5

## Dictionary that stores AdaptiAudioStreamPlayer along with their resource data.
var audio_players : Dictionary = {}
## Saves the currently playing clip
var current_playback : AdaptiAudioStreamPlayer = null
## Saves the currently playing clip resource
var current_playback_resource : AdaptiClipResource = null


## BEAT SYSTEM ##
## If enabled, the beat counting system will be active, 
## and changes can be synced to other tracks at specific bars.
var beat_system_enable : bool = true:
	set(value):
		beat_system_enable = value
		notify_property_list_changed()

## Beat System Resource
var beat_system : BeatSystemResource
var key_change_active : bool = false
var next_clip_res : AdaptiClipResource = null


func _validate_property(property):
	#if property.name == "_play" and !editor_preview:
	#	property.usage = PROPERTY_USAGE_NO_EDITOR
		
	if property.name == "_stop" and !editor_preview:
		property.usage = PROPERTY_USAGE_NO_EDITOR
	
	#if property.name == "_editor_target_clip" and !editor_preview:
	#	property.usage = PROPERTY_USAGE_NO_EDITOR
	
	if property.name == "time_fade_in" and !editor_preview:
		property.usage = PROPERTY_USAGE_NO_EDITOR
		
	if property.name == "time_fade_out" and !editor_preview:
		property.usage = PROPERTY_USAGE_NO_EDITOR
		
	if property.name == "volume_db" and !editor_preview:
		property.usage = PROPERTY_USAGE_NO_EDITOR
		
	if property.name == "pitch_scale" and !editor_preview:
		property.usage = PROPERTY_USAGE_NO_EDITOR

func _get_property_list():
	var properties = []
	
	properties.append({
		"name" : "initial_clip",
		"type" : TYPE_STRING,
		"hint" : PROPERTY_HINT_ENUM,
		"hint_string" : _array_to_string(clips)
	})
	
	properties.append({
		"name" : "shuffle_playback",
		"type" : TYPE_BOOL,
		"hint" : PROPERTY_HINT_NONE,
	})
	
	properties.append({
		"name" : "beat_system_enable",
		"type" : TYPE_BOOL,
		"hint" : PROPERTY_HINT_NONE,
	})
	
	
	## EDITOR TOOL ##
	properties.append({
		"name": "Editor Preview",
		"type": TYPE_NIL, 
		"usage": PROPERTY_USAGE_CATEGORY
	})
	
	properties.append({
		"name" : "editor_preview",
		"type" : TYPE_BOOL,
		"hint" : PROPERTY_HINT_NONE
	})
	
	#properties.append({
		#"name" : "_editor_target_clip",
		#"type" : TYPE_STRING,
		#"hint" : PROPERTY_HINT_ENUM,
		#"hint_string" : _array_to_string(clips)
	#})
	
	## PLAYBACK PROPERTYS ##
	#properties.append({
		#"name" : "_play",
		#"type" : TYPE_BOOL,
		#"hint" : PROPERTY_HINT_NONE
	#})
	
	properties.append({
		"name" : "_stop",
		"type" : TYPE_BOOL,
		"hint" : PROPERTY_HINT_NONE
	})
	
	## Volume of track, in dB. [br][b]This parameter affects all the tracks that belong to it[/b].s
	properties.append({
		"name" : "volume_db",
		"type" : TYPE_FLOAT,
		"hint" : PROPERTY_HINT_RANGE,
		"hint_string": "-80.0, 24.0"
	})
	
	## Pitch and tempo of the audio. [br][b]This parameter affects all the tracks that belong to it[/b].
	properties.append({
		"name" : "pitch_scale",
		"type" : TYPE_FLOAT,
		"hint" : PROPERTY_HINT_RANGE,
		"hint_string": "0.01, 4.0, 1.0",
	})
	
	## FADE ##
	properties.append({
		"name" : "time_fade_in",
		"type" : TYPE_FLOAT,
		"hint" : PROPERTY_HINT_RANGE,
		"hint_string" : "0.0, 10.0, 0.1"
	})
	properties.append({
		"name" : "time_fade_out",
		"type" : TYPE_FLOAT,
		"hint" : PROPERTY_HINT_RANGE,
		"hint_string" : "0.0, 10.0, 0.1"
	})
	
	return properties
	
func _array_to_string(arr:Array[AdaptiClipResource], separator:=",") -> String:
	var string = ""
	for i in arr:
		string += "Clip " + str(arr.find(i)) + separator
	return string


## -----------------------------------------------------------------------------
## INITIALIZATION
func _enter_tree():
	current_playback = null
	current_playback_resource = null
	key_change_active = false
	create_audio_players()
	initialize_beat_system()
	
func initialize_beat_system():
	if beat_system == null:
		beat_system = BeatSystemResource.new()
	if !beat_system.BarChanged.is_connected(bar_signal_emit):
		beat_system.BarChanged.connect(bar_signal_emit)
	if !beat_system.LoopBegin.is_connected(loop_begin_emit):
		beat_system.LoopBegin.connect(loop_begin_emit)
		
	if clips.size() != 0:
		var idx = int(initial_clip)
		var clip_res = clips[idx]
		update_beat_settings(clip_res)
	
func update_beat_settings(clip_res:AdaptiClipResource):
	beat_system.bpm = clip_res.bpm
	beat_system.beats_per_bar = clip_res.beats_per_bar
	
	
func _exit_tree():
	stop()
	
func create_audio_players():
	## Create AudioPlayers ##
	audio_players.clear()
	for n in get_children():
		n.queue_free()
		
	for i in clips:
		var audio = AudioManager.AUDIOPLAYER.instantiate()
		audio.stream = i.clip
		if i.clip_name:
			audio.name = i.clip_name
			
		### AUTO-ADVANCE ###
		match i.advance_type:
			0:
				audio.set_loop(true)
			1:
				audio.loop = false
				audio.set_sequence(auto_advance.bind(i))
			2:
				audio.set_loop(false)
		
		if !i.is_connected("clip_resource_changed", set_clip_resource):
			i.connect("clip_resource_changed", set_clip_resource)
		if !i.is_connected("auto_advance_changed", set_auto_advance):
			i.connect("auto_advance_changed", set_auto_advance)
		
		
		## ADD TRACK
		add_child(audio)
		audio_players[i.clip_name] = audio
		
		#audio.owner = get_tree().edited_scene_root # DEBUG



## -----------------------------------------------------------------------------
## BEAT SYSTEM SIGNALS
func bar_signal_emit(value):
	if beat_system_debug:
		print("BeatSystem: Measure count: " + str(value))
	if key_change_active:
		if current_playback_resource.key_bars.find(value) != -1:
			if Engine.is_editor_hint():
				#_editor_target_clip = "Clip %s" %clips.find(next_clip_res)
				play(next_clip_res.clip_name)
				clear_key_changes()
			else:
				on_change_loop(next_clip_res.clip_name, time_fade_in, time_fade_out)
				clear_key_changes()
	BarChanged.emit(value)
	
func loop_begin_emit():
	bar_signal_emit(1)
	LoopBegin.emit()
	
func clear_key_changes():
	key_change_active = false
	next_clip_res = null
	
	
## -----------------------------------------------------------------------------
#################
## BEAT SYSTEM ##
#################
func _process(delta):
	if process_callback == 0:
		check_track_is_playing()
		if beat_system_enable and audio_players.size() != 0:
			if playing:
				beat_system.beat_process(delta, current_playback)
			else:
				beat_system.can_first_beat = true
	
func _physics_process(delta):
	if process_callback == 1:
		check_track_is_playing()
		if beat_system_enable and audio_players.size() != 0:
			if playing:
				beat_system.beat_process(delta, current_playback)
			else:
				beat_system.can_first_beat = true

## -----------------------------------------------------------------------------
######################
## PLAYBACK METHODS ##
######################

## Play and switch to target audio track ##
func play(clip_name:=initial_clip, vol_db:=0.0, fade_in:=0.0, fade_out:=0.0):
	var childs = get_children()
	if childs.size() == 0:
		print("No clips in AudioInteractivePlayer")
		return
		
	volume_db = vol_db
	if Engine.is_editor_hint():# and editor_preview:
		if !audio_players.has(clip_name):
			print("Clip with name: " + clip_name + " not found")
			return
		var track = audio_players[clip_name]
		_play_method(track, volume_db, time_fade_in, time_fade_out)
	else:
		if !audio_players.has(initial_clip):
			print("Clip with name: " + initial_clip + " not found")
			return
		var track = audio_players[initial_clip]
		_play_method(track, vol_db, fade_in, fade_out)
		
func _play_method(_track:AdaptiAudioStreamPlayer, vol_db:=0.0, fade_in:=0.0, fade_out:=0.0):
	if playing and _track == current_playback:
		print("Clip already playing")
		return
	if current_playback != null:
		current_playback.on_fade_out(fade_out)
	_track.on_fade_in(vol_db, fade_in)
	_track.play()
	current_playback = _track
	
	## Clip Changed Signal
	var childs = get_children()
	var idx = childs.find(_track)
	var clip_resource = clips[idx]
	ClipChanged.emit(clip_resource)
	current_playback_resource = clip_resource
	update_beat_settings(current_playback_resource)

## Stop all tracks
func stop(fade_out_time:=0.0):
	var childs = get_children()
	for i in childs:
		i.on_fade_out(fade_out_time)
		
	current_playback = null
	current_playback_resource = null
	clear_key_changes()

## -----------------------------------------------------------------------------
## Play track from AudioManager
func on_play(fade_in_time:=0.0, vol_db:=0.0):
	var childs = get_children()
	if childs.size() == 0:
		print("No clips in AudioInteractivePlayer")
		return
	var idx = int(initial_clip)
	var track = childs[idx]
	volume_db = vol_db
	_play_method(track, vol_db, fade_in_time)
	
func on_stop(fade_time:=0.0, _can_destroy:=false):
	destroy = _can_destroy
	if current_playback != null:
		current_playback.on_fade_out(fade_time)
	clear_key_changes()

## Switch clip from AudioManager
func on_change_loop(loop_by_index, fade_in_time, fade_out_time):
	if typeof(loop_by_index) == TYPE_INT:
		var childs = get_children()
		var track = childs[loop_by_index]
		_play_method(track, volume_db, fade_in_time, fade_out_time)
	else:
		play(str(loop_by_index), volume_db, fade_in_time, fade_out_time)



## -----------------------------------------------------------------------------
#########################
## SETTERS AND GETTERS ##
#########################
		
func set_volume_db(value : float):
	volume_db = value
	if current_playback and is_instance_valid(current_playback):
		
		current_playback.volume_db = volume_db

## -----------------------------------------------------------------------------
## EDITOR
## Editor Playing ##
func beat_editor_play(clip_name, audio_position:float):
	var audio_stream :AdaptiAudioStreamPlayer = audio_players[clip_name]
	if playing and audio_stream == current_playback:
		print("Clip already playing")
		return
	if current_playback != null:
		current_playback.on_fade_out(0.0)
	audio_stream.on_fade_in(0.0, 0.0)
	if audio_position < 0.0:
		audio_position = 0.0
	audio_stream.play(audio_position)
	current_playback = audio_stream
	
	## Clip Changed Signal
	var childs = get_children()
	var idx = childs.find(audio_stream)
	var clip_resource = clips[idx]
	ClipChanged.emit(clip_resource)
	current_playback_resource = clip_resource
	update_beat_settings(current_playback_resource)

func set_on_playing(value):
	editor_preview = value
	if !editor_preview:
		stop()
	notify_property_list_changed()

func set_custom_res(value):
	clips.resize(value.size())
	clips = value
	for i in clips.size():
		if not clips[i]:
			clips[i] = AdaptiClipResource.new()
			clips[i].resource_name = "Clip " + str(i)
			clips[i].clip_name = "Clip " + str(i)
			clips[i].connect("clip_resource_changed", set_clip_resource)
			clips[i].connect("auto_advance_changed", set_auto_advance)
			clips[i].total_clips = clips
			#clips[i].connect("clip_name_changed", set_clip_name)
		clips[i].total_clips = clips
	
	if Engine.is_editor_hint():
		create_audio_players()
		notify_property_list_changed()
	
func set_clip_resource(clip, res):
	var idx = clips.find(res)
	get_children()[idx].stream = clip

func set_auto_advance(value, res):
	var idx = clips.find(res)
	var track : AdaptiAudioStreamPlayer = get_children()[idx]
	match value:
		0:
			track.set_loop(true)
		1:
			track.set_loop(false)
			if Engine.is_editor_hint():
				track.set_sequence(auto_advance.bind(res))
		2:
			track.set_loop(false)
		
			
func auto_advance(caller_res:AdaptiClipResource):
	if !Engine.is_editor_hint():
		if AudioManager.current_playback != self:
			## Auto-advance cancelled
			return
	
	var childs = get_children()
	var track
	if shuffle_playback:
		var idx
		randomize()
		var prev_idx = clips.find(caller_res)
		idx = randi_range(0, clips.size()-1)
		if idx == prev_idx:
			idx += 1
			if idx > clips.size()-1:
				idx = 0
		track = audio_players[audio_players.keys()[idx]]
		_print("Auto-advance to " + clips[idx].clip_name)
	else:
		#idx = int(caller_res._next_clip)
		track = audio_players[caller_res._next_clip]
		_print("Auto-advance to " + caller_res._next_clip)
	
	
	track.volume_db = volume_db
	track.play()
	current_playback = track
	current_playback_resource = clips[childs.find(track)]
	ClipChanged.emit(clips[childs.find(track)])



### ###
func get_audio_stream_player(clip_name:String) -> AudioStreamPlayer:
	if audio_players.has(clip_name):
		return audio_players[clip_name]
	else:
		return null
