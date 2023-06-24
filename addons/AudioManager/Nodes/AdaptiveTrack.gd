extends Node

signal beat
signal measure

## Here you must assign the AudioStreamPlayer that belong to each section. Outro can be omitted.
@export_group("AudioStreamPlayer Asignaments")
## This track is played only once when starting the play function
@export var intro_file : AudioStream
## These are the tracks that can be looped. the first one will play automatically after the Intro
@export var loop_files : Array[BaseAudioTrack]
## This track is played only once when calling the [b]end_music()[/b] function
@export var outro_file : AudioStream

var current_playback : AudioStreamPlayer

var intro_player = AudioStreamPlayer.new()
var outro_player = AudioStreamPlayer.new()

var measures := 1
var can_change_track = false
var can_end_track = false

# Tracking the beat and song position
var song_position = 0.0
var song_position_in_beats = 1
var sec_per_beat : float = 0.0
var last_reported_beat = 0
var beats_before_start = 0
var beat_measure_count = 2

var first_loop_playing : int = 0
var loop_target : int = 0
var loops = {}
var loops_audio_streams = []

# Fades
var tween
var transition = Transitions.new()
var fade_out_loop = 1.5
var fade_in_loop = 0.5

var volume_db = 0.0 : set = set_volume_db, get = get_volume_db
var pitch = 0.0 : set = set_pitch, get = get_pitch


func _ready():
	intro_player.stream = intro_file
	intro_player.volume_db = volume_db
	intro_player.name = "Intro"
	add_child(intro_player)
	intro_player.connect("finished", intro_finished)
	
	outro_player.stream = outro_file
	outro_player.volume_db = volume_db
	outro_player.name = "Outro"
	add_child(outro_player)
	outro_player.connect("finished", on_stop.bind(0.0, false))
	
	current_playback = null
	
	if loop_files != []:
		if loop_files[0] != null:
			sec_per_beat = 60.0 / loop_files[0].bpm
		else:
			AudioManager.debug._print("ERROR: Not found loop files")
			return
	else:
		AudioManager.debug._print("ERROR: Not found loop files")
		return
	
	for i in loop_files:
		var load_file = load(i.audio_file)
		loops[i.track_name] = load_file
	
	for n in loops:
		var audio_stream = AudioStreamPlayer.new()
		audio_stream.name = n
		audio_stream.stream = loops[n]
		add_child(audio_stream)
		
		loops_audio_streams.append(get_node(audio_stream.get_path()))
		
	for i in loops_audio_streams:
		i.connect("finished", can_loop)



######################
## PLAYBACK OPTIONS ##
######################

func on_play(fade_in := 0.0, skip_intro := false, loop_index := 0):
	if loop_index > loops_audio_streams.size() - 1:
		AudioManager.debug._print("DEBUG: Not found loop index")
		return
	
	first_loop_playing = loop_index
	
	if intro_file != null:
		if not intro_player.is_connected("finished", intro_finished):
			intro_player.connect("finished", intro_finished)
		
		intro_player.volume_db = volume_db
		loops_audio_streams[loop_index].volume_db = volume_db
		transition.request_play_transition(self, intro_player, fade_in)
		current_playback = intro_player
	else:
		on_play_loop(fade_in, loop_index)
		AudioManager.debug._print("DEBUG: Track without intro")


func on_play_loop(fade_time, loop_index):
	if loop_index > loops_audio_streams.size() - 1:
		AudioManager.debug._print("DEBUG: Not found loop index")
		return
	
	loops_audio_streams[loop_index].volume_db = volume_db
	
	sec_per_beat = 60.0 / loop_files[loop_index].bpm
	transition.request_play_transition(self,
	loops_audio_streams[loop_index], fade_time)
	AudioManager.debug._print("DEBUG: Skip intro")
	
	current_playback = loops_audio_streams[loop_index]

## No disponible
func on_reset():
	for i in get_children():
		i.stop()
	on_play()

func change_loop(index, fade_in, fade_out):
	if current_playback == loops_audio_streams[index]:
		can_change_track = false
		AudioManager.debug._print("DEBUG: Loop continue")
		return
		
	can_end_track = false # Stop offset Outro by key
	
	## Set fade_times values for change by key
	fade_in_loop = fade_in
	fade_out_loop = fade_out
	
	## Check if current_playback is a Loop
	var current_loop_index = loops_audio_streams.find(current_playback)
	
	if current_loop_index != -1:
		## Check if Loop has keys
		if loop_files[current_loop_index].keys_loop_in_beat != [] \
			or loop_files[current_loop_index].keys_loop_in_measure != []:
			
			loop_target = index
			can_change_track = true
			AudioManager.debug._print("DEBUG: Loop prepare to change")
				
		else:
			## Inmediate Change Loop
			loops_audio_streams[index].volume_db = volume_db
			if tween:
				tween.kill()
			loop_target = index
			change_track(current_playback, loops_audio_streams[index], fade_out, fade_in)
			AudioManager.debug._print("DEBUG: Change Loop")
	
	## Back to the loop from Outro
	if current_playback == outro_player:
		if outro_player.is_connected("finished", on_stop):
			outro_player.disconnect("finished", on_stop)
		change_track(outro_player, loops_audio_streams[index], fade_out, fade_in)
		AudioManager.debug._print("DEBUG: Outro to loop")
		
	## Back to the loop from Intro
	#if 


func on_outro(fade_out, fade_in, can_destroy):
	if loops_audio_streams.has(current_playback) == false:
		can_end_track = false
		AudioManager.debug._print("DEBUG: Can change from intro or outro")
		return
	
	can_change_track = false
	
	## Set fade_times values for change by key
	fade_in_loop = fade_in
	fade_out_loop = fade_out
	
	## Check if current_playback is a Loop
	var current_loop_index = loops_audio_streams.find(current_playback)
	
	if outro_file != null:
		if loop_files[current_loop_index].keys_end_in_beat != [] \
			or loop_files[current_loop_index].keys_end_in_measure != []:
			
			if not outro_player.is_connected("finished", on_stop):
				outro_player.connect("finished", on_stop.bind(0.0, false))
				
			can_end_track = true
			AudioManager.debug._print("DEBUG: Outro prepare to change")
				
		else:
			## Inmediate change to Outro
			if not outro_player.is_connected("finished", on_stop):
				outro_player.connect("finished", on_stop.bind(0.0, false))
			
			outro_player.volume_db = volume_db
			
			if tween:
				tween.kill()
				
			## Mute queues audios
			for i in get_children():
				if i != outro_player and i != current_playback:
					i.stop()
					
			transition.request_change_transition(self, current_playback,
			outro_player, fade_out, fade_in)
			outro_player.play()
			current_playback = outro_player
			AudioManager.debug._print("DEBUG: Go to the outro")
	else:
		## No outro file
		on_stop(fade_out, can_destroy)


func on_stop(fade_out, can_destroy):
	if intro_player.is_connected("finished", intro_finished):
		intro_player.disconnect("finished", intro_finished)
	if outro_player.is_connected("finished", on_stop):
		outro_player.disconnect("finished", on_stop)
		
	if tween:
		tween.kill()
	
	if can_destroy:
		if fade_out != 0.0:
			transition.fade_out(self, current_playback, fade_out, can_destroy)
		else:
			destroy_track()
	else:
		if fade_out != 0.0:
			for i in get_children():
				transition.fade_out(self, i, fade_out, can_destroy)
		else:
			for i in get_children():
				i.stop()
	
	AudioManager.debug._print("DEBUG: " + self.name + " maintrack end")
	current_playback = null
	
	
	#############
	## Process ##
	#############
	
func intro_finished():
	loops_audio_streams[first_loop_playing].play()
	current_playback = loops_audio_streams[first_loop_playing]
	
func can_loop():
	if loops_audio_streams.has(current_playback):
		var current_loop_index = loops_audio_streams.find(current_playback)
		if loop_files[current_loop_index].loop:
			measures = 1
			beat_measure_count = 2
			last_reported_beat = 0
			song_position_in_beats = 0
			loops_audio_streams[current_loop_index].play()
		else:
			on_outro(1.5, 0.5, false)
	
	
## Measure and Beat Count
func _physics_process(delta):
	if loop_files != []:
		var current_loop_index = loops_audio_streams.find(current_playback)
		if current_loop_index != -1:
			if loops_audio_streams[current_loop_index].playing:
				song_position = loops_audio_streams[current_loop_index].get_playback_position()\
				+ AudioServer.get_time_since_last_mix()
				
				song_position -= AudioServer.get_output_latency()
				song_position_in_beats = int(floor(song_position / sec_per_beat)) + beats_before_start
				_report_beat(current_loop_index)

func _report_beat(current_loop_index):
	if last_reported_beat < song_position_in_beats:
		if beat_measure_count > loop_files[current_loop_index].metric:
			measures += 1
			beat_measure_count = 1
			print(measures)
			emit_signal("measure", measures)
			change_measure_tracks()
			
			
		emit_signal("beat", song_position_in_beats)
		
		last_reported_beat = song_position_in_beats
		beat_measure_count += 1
		
		change_beat_tracks()
		
func change_measure_tracks():
	var current_loop_index = loops_audio_streams.find(current_playback)
	## Change Loops by Keys ##
	if loop_files[current_loop_index].keys_loop_in_measure.has(measures) \
	and can_change_track:
		change_track(current_playback, loops_audio_streams[loop_target])
		
	## Change to End by Keys ##
	if loop_files[current_loop_index].keys_end_in_measure.has(measures) \
		and can_end_track:
			
		can_end_track = false
		change_outro(fade_out_loop, fade_in_loop)
		
func change_beat_tracks():
	var current_loop_index = loops_audio_streams.find(current_playback)
	## Change Loops by Keys ##
	if loop_files[current_loop_index].keys_loop_in_beat.has(song_position_in_beats + 1) \
	and can_change_track:
		change_track(current_playback, loops_audio_streams[loop_target])
		
	## Change to End by Keys ##
	if loop_files[current_loop_index].keys_end_in_beat.has(song_position_in_beats + 1) \
		and can_end_track:
		
		can_end_track = false
		change_outro(fade_out_loop, fade_in_loop)
		
func change_outro(fade_out, fade_in):
	outro_player.volume_db = volume_db
	
	if tween:
		tween.kill()
	
	for i in get_children():
		if i != outro_player and i != current_playback:
			i.stop()
			
	transition.request_change_transition(self, current_playback,
	outro_player, fade_out, fade_in)
	outro_player.play()
	current_playback = outro_player
	
func change_track(from_track, to_track, fade_out = fade_out_loop, fade_in = fade_in_loop):
	
	var loop_index = loops_audio_streams.find(to_track)
	
	can_change_track = false
	measures = 1
	last_reported_beat = 0
	song_position_in_beats = 0
	sec_per_beat = 60.0 / loop_files[loop_index].bpm
	
	## For the Fast Keys ## Revisar funcionamiento
	to_track.volume_db = volume_db
	if tween:
		tween.kill()
		
	## Mute queues audios
	for i in get_children():
		if i != to_track and i != from_track:
			#transition.fade_out(self, i, fade_out)
			i.stop()
	
	
	transition.request_change_transition(self, from_track,
	to_track, fade_out, fade_in)
	to_track.play()
	
	current_playback = to_track
	
func destroy_track():
	for i in get_children():
		i.stop()
		
	queue_free()
	
	
	
	#########################
	## Setters and Getters ##
	#########################
	
func get_stream_playing():
	var childs = get_children()
	for i in childs:
		if i.playing:
			return i
			
	return null

func set_volume_db(value : float):
	volume_db = value
	for i in get_children():
		i.volume_db = volume_db
	
func get_volume_db():
	return volume_db
	
func set_pitch(value):
	pass

func get_pitch():
	return pitch
