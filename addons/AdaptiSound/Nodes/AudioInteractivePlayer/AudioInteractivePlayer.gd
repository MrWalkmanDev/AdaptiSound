@tool
extends AdaptiNode
class_name AudioInteractivePlayer
## This node allows you to store multiple audio clips that can be set to play in
## different ways but only one at a time. [br]
## [b]It has an editor preview[/b], and you can control the fade in and fade out
## times of transitions.


signal ClipChanged(clip_resource:AdaptiClipResource)

## Beat System Signals
signal BeatChanged(value)
signal BarChanged(value)
signal LoopBegin

## Update Editor Preview ##
signal clips_array_changed


## Contains the audio clips to be played.
@export var clips : Array[AdaptiClipResource]: set = set_custom_res

## The first clip to play at the start
var initial_clip:String:set=set_initial_clip, get=get_initial_clip
		
		
## If true, all tracks are set to random auto-advance
var shuffle_playback : bool = false:
	set(value):
		if value == true:
			for i in clips:
				i.advance_type = 1
		shuffle_playback = value

## Fade in time of the clip being played
var fade_in_time : float = 1.0
## Fade time of the clip that stops at the transition
var fade_out_time : float = 1.5

## Dictionary that stores AdaptiAudioStreamPlayer along with their resource data.
var audio_players : Dictionary = {}
#var audio_players_by_resource : Dictionary = {}
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
	
	#### FADE ##
	#properties.append({
		#"name" : "fade_in_time",
		#"type" : TYPE_FLOAT,
		#"hint" : PROPERTY_HINT_RANGE,
		#"hint_string" : "0.0, 10.0, 0.1"
	#})
	#properties.append({
		#"name" : "fade_out_time",
		#"type" : TYPE_FLOAT,
		#"hint" : PROPERTY_HINT_RANGE,
		#"hint_string" : "0.0, 10.0, 0.1"
	#})
	
	return properties
	
func _array_to_string(arr:Array[AdaptiClipResource], separator:=",") -> String:
	var string = ""
	for i in arr:
		string += i.clip_name + separator
	return string


## -----------------------------------------------------------------------------
## INITIALIZATION
func _enter_tree():
	current_playback = null
	current_playback_resource = null
	key_change_active = false
	create_audio_players()
	initialize_beat_system()
	enable_process_mode(false)
	
func enable_process_mode(value:bool):
	if process_callback == 0:
		set_process(value)
		set_physics_process(false)
	else:
		set_physics_process(value)
		set_process(false)
	
func initialize_beat_system():
	if beat_system == null:
		beat_system = BeatSystemResource.new()
	if !beat_system.BeatChanged.is_connected(beat_signal_emit):
		beat_system.BeatChanged.connect(beat_signal_emit)
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
	if Engine.is_editor_hint():
		stop()
	
func create_audio_players():
	## Create AudioPlayers ##
	audio_players.clear()
	#audio_players_by_resource.clear()
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
				audio.set_callback(auto_advance.bind(i))
			2:
				audio.set_loop(false)
		
		if !i.is_connected("clip_resource_changed", set_clip_resource):
			i.connect("clip_resource_changed", set_clip_resource)
		if !i.is_connected("auto_advance_changed", set_auto_advance):
			i.connect("auto_advance_changed", set_auto_advance)
		
		
		## ADD TRACK
		add_child(audio)
		audio_players[i.clip_name] = audio
		#audio_players_by_resource[i] = audio



## -----------------------------------------------------------------------------
#################
## BEAT SYSTEM ##
#################
func beat_signal_emit(value):
	BeatChanged.emit(value)
	
func bar_signal_emit(value):
	if beat_system_debug:
		_print("BeatSystem: Measure count: " + str(value))
	if key_change_active:
		if current_playback_resource.key_bars.find(value) != -1:
			if Engine.is_editor_hint():
				play_from_editor(next_clip_res.clip_name, volume_db, fade_in_time, fade_out_time)
				clear_key_changes()
			else:
				var track = get_audio_stream_player(next_clip_res.clip_name)
				_play_method(track, volume_db, fade_in_time, fade_out_time)
				clear_key_changes()
	BarChanged.emit(value)
	
func loop_begin_emit():
	bar_signal_emit(1)
	LoopBegin.emit()
	
func clear_key_changes():
	key_change_active = false
	next_clip_res = null
	
func _process(delta):
	check_track_is_playing()
	if beat_system_enable and audio_players.size() != 0:
		if playing:
			beat_system.beat_process(delta, current_playback)
		else:
			beat_system.can_first_beat = true
	
func _physics_process(delta):
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

## Play and switch to target audio track from Audio Editor Preview ##
func play_from_editor(clip_name:=initial_clip, vol_db:=0.0, fade_in:=0.0, fade_out:=0.0):
	var childs = get_children()
	if childs.size() == 0:
		_print("No clips in AudioInteractivePlayer")
		return
		
	volume_db = vol_db

	if !audio_players.has(clip_name):
		_print("Clip with name: " + clip_name + " not found")
		return
		
	## Check clip advance_type ##
	var track = audio_players[clip_name]
	var clip_resource = get_clip_resource(clip_name)
	if clip_resource.advance_type == 2: ## advance_type = ONCE
		if not track.finished.is_connected(on_stop):
			track.finished.connect(on_stop)
	
	if current_playback_resource:
		if !current_playback_resource.can_be_interrupted:
			_print("Clip " + current_playback_resource.clip_name + " has clip_transition DISABLED")
			return
		else:
			_play_method(track, volume_db, fade_in, fade_out)
	else:
		_play_method(track, volume_db, 0.0, fade_out)
	enable_process_mode(true)
	
		
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
	destroy = false
	if audio_players.size() == 0:
		_print("No clips in AudioInteractivePlayer")
		return
	
	enable_process_mode(true)
	
	var track = get_audio_stream_player(initial_clip)
	volume_db = vol_db
	_play_method(track, vol_db, fade_in_time)
	
func on_stop(fade_time:=0.0, _can_destroy:=false):
	destroy = _can_destroy
	if current_playback != null:
		current_playback.on_fade_out(fade_time)
	
	enable_process_mode(false)
	current_playback = null
	current_playback_resource = null
	clear_key_changes()
	
	## If AudioManager not current playback ##
	if Engine.is_editor_hint():
		return
	if AudioManager.current_playback == self:
		AudioManager.current_playback = null
		

## Switch clip from AudioManager
func on_change_clip(clip_name_index, fade_in:float, fade_out:float):
	if !current_playback_resource.can_be_interrupted:
		_print("Clip " + current_playback_resource.clip_name + " cannot be interrupted by another clip")
		return

	## Loop by Index ##
	if typeof(clip_name_index) == TYPE_INT:
		## Check Transitions Keys ##
		if clip_name_index > clips.size() - 1:
			_print("Clip index " + str(clip_name_index) + " not found")
			return
		var clip_resource : AdaptiClipResource = clips[clip_name_index]
		var clip_name : String = audio_players.keys()[clip_name_index]
		_change_clip(clip_resource, clip_name, fade_in, fade_out)
		
	## Loop by String (Name) ##
	elif typeof(clip_name_index) == TYPE_STRING:
		## Check Transitions Keys ##
		if !audio_players.has(clip_name_index):
			_print("Clip name " + clip_name_index + " not found")
			return
		var clip_resource : AdaptiClipResource = get_clip_resource(clip_name_index)
		_change_clip(clip_resource, clip_name_index, fade_in, fade_out)
		
func _change_clip(clip_resource:AdaptiClipResource, clip_name:String, fade_in:float, fade_out:float):
	var track = get_audio_stream_player(clip_name)
	
	## Check clip advance_type ##
	if clip_resource.advance_type == 2: ## advance_type = ONCE
		if not track.finished.is_connected(check_track_callback):
			track.finished.connect(check_track_callback)
		
	if current_playback_resource.key_bars.size() != 0:
		if clip_resource == current_playback_resource:
			_print("Clip already playing")
			return
		fade_in_time = fade_in
		fade_out_time = fade_out
		key_change_active = true
		next_clip_res = clip_resource
		return
		
	_play_method(track, volume_db, fade_in, fade_out)


func check_track_callback():
	if playing:
		#_print("Cancel Stop")
		return
	on_stop()


## -----------------------------------------------------------------------------
## EDITOR
## Editor Playing ##
func beat_editor_play(clip_name, audio_position:float):
	var audio_stream :AdaptiAudioStreamPlayer = audio_players[clip_name]
	if playing and audio_stream == current_playback:
		_print("Clip already playing")
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
		clips[i].total_clips = clips
	
	if Engine.is_editor_hint():
		clips_array_changed.emit()
		notify_property_list_changed()
	
func set_clip_resource(clip, res:AdaptiClipResource) -> void:
	var idx = clips.find(res)
	get_children()[idx].stream = clip

func set_auto_advance(value:int, res:AdaptiClipResource) -> void:
	var idx = clips.find(res)
	var track : AdaptiAudioStreamPlayer = get_children()[idx]
	match value:
		0:
			track.set_loop(true)
			track.callback = false
		1:
			track.set_loop(false)
			if Engine.is_editor_hint():
				track.set_callback(auto_advance.bind(res))
		2:
			track.set_loop(false)
			track.callback = false
		
			
func auto_advance(caller_res:AdaptiClipResource) -> void:
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
		track = audio_players[caller_res._next_clip]
		_print("Auto-advance to " + caller_res._next_clip)
	
	
	track.volume_db = volume_db
	track.play()
	current_playback = track
	current_playback_resource = clips[childs.find(track)]
	ClipChanged.emit(clips[childs.find(track)])


## -----------------------------------------------------------------------------
#########################
## SETTERS AND GETTERS ##
#########################

func set_volume_db(value : float):
	volume_db = value
	if current_playback and is_instance_valid(current_playback):
		current_playback.volume_db = volume_db

func get_audio_stream_player(clip_name:String) -> AudioStreamPlayer:
	if audio_players.has(clip_name):
		return audio_players[clip_name]
	else:
		return null

func get_clip_resource(clip_name:String) -> AdaptiClipResource:
	var clip : AdaptiClipResource = null
	for i in clips:
		if i.clip_name == clip_name:
			clip = i
			break
	return clip
	
## Initial Clip ##
func set_initial_clip(clip_name:String) -> AudioInteractivePlayer:
	initial_clip = clip_name
	return self
func get_initial_clip() -> String:
	return initial_clip

## Clip can be interrupted ##
func set_can_be_interrupted(clip_name:String, value:bool) -> AudioInteractivePlayer:
	get_clip_resource(clip_name).can_be_interrupted = value
	return self
