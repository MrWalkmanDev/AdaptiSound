@tool 
extends AdaptiNode

signal measure
signal end_track

const AUDIOPLAYER = preload("res://addons/AdaptiSound/Nodes/ParallelTrack/Audio_Stream.tscn")

@export_group("Intro Section")
## This track is played only once, when calling the [b]play_music()[/b] function.
@export var intro_file : AudioStream

@export_group("Loops Section")
## These are the tracks that can be looped. The first one will play automatically after the Intro.
@export var loops : Array[LoopResource] : set = set_custom_res, get = get_custom_res

@export_group("Outro Section")
## This track is played only once when calling the [b]end_music()[/b] function.
@export var outro_file : AudioStream
## If true, the track will be able to return from the Outro to the loops section. 
@export var outro_to_loop : bool = false



###############
## Variables ##
###############

var current_playback : AudioStreamPlayer

var intro_player
var outro_player

var can_change_track = false
var can_end_track = false

# Tracking the beat and song position
var song_position = 0.0
var song_position_in_beats = 1
var sec_per_beat : float = 0.0
var last_reported_beat = 0
var beats_before_start = 0

var can_beat = false
var can_first_beat = true
var _beat = 0
var beat_measure_count = 1
var measures = 1

# Loop Variables
var first_loop_playing : int = 0
var loop_target : int = 0
var loops_audio_streams = {}
var loop_keys_measure = []
var end_keys_measure = []

# Fades
var fade_out_loop = 1.5
var fade_in_loop = 0.5

# Random Sequence Track
var rng = RandomNumberGenerator.new()



func _enter_tree():
	if Engine.is_editor_hint():
		return
		
	rng.randomize()
	
	intro_player = AUDIOPLAYER.instantiate()
	intro_player.set_bus(bus)
	intro_player.loop = false
	intro_player.stream = intro_file
	intro_player.name = "Intro"
	add_child(intro_player)
	intro_player.connect("finished", intro_finished)
	
	outro_player = AUDIOPLAYER.instantiate()
	outro_player.set_bus(bus)
	outro_player.loop = false
	outro_player.stream = outro_file
	outro_player.name = "Outro"
	add_child(outro_player)
	
	current_playback = null
	
	## Check for loop files ##
	if loops != []:
		if loops[0] != null:
			sec_per_beat = 60.0 / loops[0].bpm
		else:
			AudioManager.debug._print("ERROR: Not found loop files")
			return
	else:
		AudioManager.debug._print("ERROR: Not found loop files")
		return
	
	## Load loops audio files ##
	for i in loops:
		var layers_audio_streams = []
		for layer in i.layers:
			if layer.audio_stream != null:
				## For AudioStream Loops ##
				var audio_stream = AUDIOPLAYER.instantiate()
				audio_stream.loop = layer.loop
				audio_stream.set_bus(bus)
				audio_stream.name = layer.layer_name
				audio_stream.stream = layer.audio_stream
				audio_stream.groups = layer.groups
				audio_stream.on_mute = layer.mute ## Layers muteadas
				
				if i.random_sequence:
					audio_stream.random_sequence = true
					audio_stream.connect("audio_finished", change_layer_random_sequence)
				
				add_child(audio_stream)
				
				layers_audio_streams.append(get_node(audio_stream.get_path()))
		
		loops_audio_streams[loops.find(i)] = layers_audio_streams

	set_pitch_scale(pitch_scale)
	set_volume_db(volume_db)

######################
## PLAYBACK OPTIONS ##
######################

func on_play(fade_in : float, skip_intro := false, loop_index := 0):
	intro_player.volume_db = volume_db
	
	if skip_intro:
		change_playback(loops_audio_streams[loop_index][first_loop_playing])
		change_track(loop_index, 0.0, fade_in)
		AudioManager.debug._print("DEBUG: Track without intro")
		return
	
	for i in get_children():
		if i != intro_player:
			i.on_fade_out(1.5)
	
	## Check if index is correct ##
	if loop_index > loops_audio_streams.size() - 1:
		AudioManager.debug._print("DEBUG: Not found loop index")
		return
	
	first_loop_playing = loop_index
	
	## Check if there is Intro ##
	if intro_file != null:
		if not intro_player.is_connected("finished", intro_finished):
			intro_player.connect("finished", intro_finished)
			
		if fade_in != 0.0:
			intro_player.on_fade_in(volume_db, fade_in)
		else:
			intro_player.volume_db = volume_db
			
		intro_player.play()
		change_playback(intro_player)
	else:
		change_playback(loops_audio_streams[loop_index][first_loop_playing])
		change_track(loop_index, 0.0, fade_in)
		AudioManager.debug._print("DEBUG: Track without intro")


func on_change_loop(loop_index : int, fade_out : float, fade_in : float):
	## Check if index is correct ##
	if loop_index > (loops_audio_streams.size() - 1):
		AudioManager.debug._print("DEBUG: Not found loop index")
		return
		
	## For delay outro
	if outro_to_loop:
		can_end_track = false
	
	## Verify if target loop is same loop ##
	if loops_audio_streams[loop_index].has(current_playback):#if current_playback == loops_audio_streams[loop_index][0]:
		can_change_track = false
		AudioManager.debug._print("DEBUG: Loop continue")
		return
	
	## Set fade_times values for change by key ##
	fade_in_loop = fade_in
	fade_out_loop = fade_out
	
	## Check if current_playback is a Loop ##
	if current_playback == intro_player:
		AudioManager.debug._print("DEBUG: Can`t change from intro")
		return
	
	## Check if can change from Outro
	if current_playback == outro_player:
		if outro_to_loop:
			if outro_player.is_connected("finished", on_stop):
				outro_player.disconnect("finished", on_stop)
				
			#beat_measure_count = 1 ## only inmediate
			change_track(loop_index, fade_out, fade_in)
			AudioManager.debug._print("DEBUG: Outro to loop")
			return
		else:
			AudioManager.debug._print("DEBUG: Outro to loop is disable")
			return
	
	## Check keys in loop ##
	var current_loop_idx : int = get_loop_index(current_playback)
	
	if loops[current_loop_idx].keys_loop_in_measure != "":
		loop_target = loop_index
		can_change_track = true
		AudioManager.debug._print("DEBUG: Prepare loop change")
	
	else:
		change_track(loop_index, fade_out, fade_in)


func on_outro(fade_out, fade_in):
	## Check if current_playback is loop ##
	if current_playback == intro_player or current_playback == outro_player:
		can_end_track = false
		AudioManager.debug._print("DEBUG: No loop playing")
		return
	
	if current_playback == null:
		AudioManager.debug._print("DEBUG: No loop playing")
		return
		
	can_change_track = false
	fade_in_loop = fade_in
	fade_out_loop = fade_out
	
	var current_loop_index : int = get_loop_index(current_playback)
	
	## Connect Outro finished signal
	if not outro_player.is_connected("finished", on_stop):
		outro_player.connect("finished", on_stop.bind(0.0))
	
	## Check end keys ##
	if loops[current_loop_index].keys_end_in_measure != "":
		can_end_track = true
		AudioManager.debug._print("DEBUG: Prepare to outro change")
		
	else:
		change_outro(current_loop_index, fade_out, fade_in)


func on_mute_layers(layers_names : Array, mute_state : bool, fade_time : float, loop_target := -1):
	## Check if current_playback is loop ##
	if current_playback == outro_player or current_playback == intro_player:
		AudioManager.debug._print("DEBUG: No loop playing")
		return
	
	## Mute Process ##
	var loop_index = loop_target
	if loop_index == -1:
		loop_index = get_loop_index(current_playback)
		
	
	## All layers mute or unmute ##
	if layers_names == []:
		for layer in loops_audio_streams[loop_index]:
			if mute_state:
				layer.on_fade_out(fade_time, false)
			else:
				layer.on_fade_in(volume_db, fade_time)
			layer.on_mute = mute_state
	
	## Selected target layers ##
	for i in layers_names:
		if typeof(i) == TYPE_INT:
			if i > loops[loop_index].layers.size() - 1:
				AudioManager.debug._print("DEBUG: Invalid layer index")
				return
			else:
				var layer = loops_audio_streams[loop_index][i]
				if mute_state:
					layer.on_fade_out(fade_time, false)
				else:
					layer.on_fade_in(volume_db, fade_time)
				layer.on_mute = mute_state
				
		if typeof(i) == TYPE_STRING:
			for layer in loops_audio_streams[loop_index]:
				## Layer Groups ##
				if layer.groups.has(i):
					if mute_state:
						layer.on_fade_out(fade_time, false)
					else:
						layer.on_fade_in(volume_db, fade_time)
					layer.on_mute = mute_state
						
				## Layer Names ##
				if layer.name == i:
					if mute_state:
						layer.on_fade_out(fade_time, false)
					else:
						layer.on_fade_in(volume_db, fade_time)
					layer.on_mute = mute_state


func on_stop(fade_out : float):
	## Disconnect signals ## 
	if intro_player.is_connected("finished", intro_finished):
		intro_player.disconnect("finished", intro_finished)
	if outro_player.is_connected("finished", on_stop):
		outro_player.disconnect("finished", on_stop)
	
	## Reset loops sequences
	for i in loops:
		i.first_sequence = true
	
	## Stop all audio streams ##
	for i in get_children():
		i.on_fade_out(fade_out)
	
	current_playback = null
	
	#emit_signal("end_track") ## Maybe not necesary
	
	## If AudioManager not current playback ##
	if AudioManager.current_playback == self:
		AudioManager.current_playback = null
		
		
func play_layer(layer_names : Array, fade_time := 2.0):
	var loop_index = get_loop_index(current_playback)
	if loop_index != -1:
		play_loop(loop_index, fade_time)
	
func stop_layer(layer_names : Array, fade_time := 2.0):
	if current_playback != intro_player or current_playback != outro_player:
		on_mute_layers(layer_names, true, fade_time)



	####################
	## PLAYBACK TOOLS ##
	####################


func change_track(loop_index : int, fade_out  : float, fade_in : float):
	## Check if current_playback is loop ##
	if current_playback == intro_player:
		AudioManager.debug._print("DEBUG: No loop playing")
		return
	
	if current_playback == null:
		AudioManager.debug._print("DEBUG: No loop playing")
		return
		
	if current_playback == outro_player and outro_to_loop:
		outro_player.on_fade_out(fade_out)
		play_loop(loop_index, fade_in)
		return
	
	## Stop Current Loop ##
	for i in loops_audio_streams[get_loop_index(current_playback)]:
		i.on_fade_out(fade_out)
	
	## Play New Loop ##
	play_loop(loop_index, fade_in)


func play_loop(loop_index : int, fade_time : float):
	can_change_track = false
	reset_beat_parameters(loop_index)
	
	## Sequence Track ##
	if loops[loop_index].random_sequence:
		var layer_playback_idx = -1
		if loops[loop_index].first_sequence:
			loops[loop_index].first_sequence = false
			layer_playback_idx = loops[loop_index].first_playback_idx
			
		var current_loop_idx = get_loop_index(current_playback)
		var current_audio_stream_idx
		if current_loop_idx != -1:
			current_audio_stream_idx = loops_audio_streams[current_loop_idx].find(current_playback)
		
		if layer_playback_idx == -1:
			layer_playback_idx = rng.randi_range(0, (loops[loop_index].layers.size() - 1))
			if layer_playback_idx == current_audio_stream_idx:
				layer_playback_idx += 1
				if layer_playback_idx > (loops[loop_index].layers.size() - 1):
					layer_playback_idx = 0
					
		#for i in loops_audio_streams[loop_index]:
		#	if i != loops_audio_streams[loop_index][layer_playback_idx]:
		#		i.on_mute = true
		
		#loops_audio_streams[loop_index][layer_playback_idx].on_mute = false
		loops_audio_streams[loop_index][layer_playback_idx].volume_db = volume_db
		loops_audio_streams[loop_index][layer_playback_idx].on_fade_in(volume_db, fade_time)
		loops_audio_streams[loop_index][layer_playback_idx].play()
		
		change_playback(loops_audio_streams[loop_index][layer_playback_idx])
		
	## Play layers ##
	else:
		for i in range(loops[loop_index].layers.size()):
			## Check mute layers ##
			if loops[loop_index].layers[i].mute:
				loops_audio_streams[loop_index][i].stop_tween()
				loops_audio_streams[loop_index][i].volume_db = -50.0
				loops_audio_streams[loop_index][i].on_mute = true # Mute Layer
			else:
				loops_audio_streams[loop_index][i].volume_db = volume_db
				loops_audio_streams[loop_index][i].on_fade_in(volume_db, fade_time)
				loops_audio_streams[loop_index][i].on_mute = false
				
				
			loops_audio_streams[loop_index][i].play()
		
		change_playback(loops_audio_streams[loop_index][0])


func change_outro(current_loop_index : int, fade_out : float, fade_in : float):
	can_end_track = false
	if outro_player == null:
		#AudioManager.debug._print("DEBUG: No outro file, use stop_music")
		on_stop(fade_out)
		return
		
	outro_player.volume_db = volume_db
	
	## Connect signal for outro finished ##
	if not outro_player.is_connected("finished", on_stop):
		outro_player.connect("finished", on_stop.bind(fade_out))
	
	## Stop current loop ##
	for i in loops_audio_streams[current_loop_index]:
		i.on_fade_out(fade_out)
	
	## Play outro ##
	outro_player.on_fade_in(volume_db, fade_in)
	outro_player.play()
	
	change_playback(outro_player)
	
	
func set_sequence(method):
	sequence = true
	method_sequence = method
	

func change_layer_random_sequence(audio_stream):
	var loop_index = get_loop_index(audio_stream)
	change_track(loop_index, 0.0, 0.0)


func change_playback(playback):
	current_playback = playback
	if playback != intro_player and playback != outro_player:
		
		var current_loop_index = get_loop_index(playback)
		
		loop_keys_measure.clear()
		var loop_keys = loops[current_loop_index].keys_loop_in_measure.split(",")
		for key in loop_keys:
			loop_keys_measure.append(int(key))
		
		end_keys_measure.clear()
		var end_keys = loops[current_loop_index].keys_end_in_measure.split(",")
		for key in end_keys:
			end_keys_measure.append(int(key))


func reset_beat_parameters(loop_index : int):
	beat_measure_count = 1
	measures = 1
	last_reported_beat = 0
	song_position_in_beats = 0
	_beat = 0
	sec_per_beat = 60.0 / loops[loop_index].bpm



#############
## PROCESS ##
#############

func _process(delta):
	if Engine.is_editor_hint():
		return
		
		
	check_track_is_playing()
	
	## Beat Count ##
	if loops != []:
		## Check if is loop ##
		if current_playback != intro_player and current_playback != outro_player:
			if current_playback != null and current_playback.playing:
				var current_loop_index = get_loop_index(current_playback)
				#song_position = loops_audio_streams[current_loop_index].get_playback_position()\
				#+ AudioServer.get_time_since_last_mix()
				song_position = current_playback.get_playback_position()\
				+ AudioServer.get_time_since_last_mix()
				
				song_position -= AudioServer.get_output_latency()
				song_position_in_beats = int(floor(song_position / sec_per_beat)) + beats_before_start
				
				report_beat(current_loop_index)
				
func report_beat(current_loop_index : int):
	## First Beat (Loop) ##
	if song_position_in_beats <= 0 \
	and last_reported_beat == loops[current_loop_index].total_beat_count - 1 \
	and can_first_beat:
		can_first_beat = false
		_beat = 0
		beat_measure_count = 1
		measures = 1
		
		if show_measure_count:
			AudioManager.debug._print("DEBUG: Measure count: " + str(measures) + "Loop")
		
		change_track_by_key(current_loop_index)
	if _beat < song_position_in_beats:
		can_beat = true
	
	## Beat Report ##
	if can_beat:
		can_beat = false
		_beat += 1
		beat_measure_count += 1
		if beat_measure_count > loops[current_loop_index].metric:
			measures += 1
			beat_measure_count = 1
			can_first_beat = true
			change_track_by_key(current_loop_index)
			emit_signal("measure")
			
			if show_measure_count:
				AudioManager.debug._print("DEBUG: Measure count: " + str(measures))
		
		last_reported_beat = song_position_in_beats

func change_track_by_key(current_loop_index : int):
	## Check loop keys measures ##
	var contain_key = loop_keys_measure.has(measures)
		
	if contain_key and can_change_track:
		change_track(loop_target, fade_out_loop, fade_in_loop)
		return
	
	
	## Check end keys measures ##
	var contain_end_key = end_keys_measure.has(measures)
		
	if contain_end_key and can_end_track:
		change_outro(current_loop_index, fade_out_loop, fade_in_loop);
		return
		

func intro_finished():
	play_loop(first_loop_playing, 0.0)
	
	
func get_loop_index(audio_stream : AudioStreamPlayer):
	var index = -1
	for i in loops_audio_streams.keys():
		if loops_audio_streams[i].has(current_playback):
			index = i
			break
			
	return index


## EDITOR ##

func set_custom_res(value):
	loops.resize(value.size())
	loops = value
	for i in loops.size():
		if not loops[i]:
			loops[i] = LoopResource.new()
			loops[i].resource_name = "LoopRes"
	
func get_custom_res():
	return loops
