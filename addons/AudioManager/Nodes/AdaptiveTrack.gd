extends Node

signal beat
signal measure

## Here you must assign the AudioStreamPlayer that belong to each section. Outro can be omitted.
@export_group("AudioStreamPlayer Asignaments")
## This track is played only once when starting the play function
@export var intro_file : Resource
## These are the tracks that can be looped. the first one will play automatically after the Intro
@export var loop_files : Array[BaseAudioTrack]
## This track is played only once when calling the [b]end_music()[/b] function
@export var outro_file : Resource

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

var loop_playing : int = 0
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
	add_child(intro_player)
	intro_player.connect("finished", intro_finished)
	
	outro_player.stream = outro_file
	outro_player.volume_db = volume_db
	add_child(outro_player)
	outro_player.connect("finished", destroy_track)
	
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
		
		
## PLAYBACK OPTIONS ##

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

## Play Functions
	
func on_play(fade_in := 0.0, skip_intro := false, loop_index := 0):
	if loop_index > loops_audio_streams.size() - 1:
		AudioManager.debug._print("DEBUG: Not found loop index")
		return
	
	loop_playing = loop_index
	
	if intro_file != null:
		transition.request_play_transition(self, intro_player, fade_in)
	else:
		AudioManager.debug._print("DEBUG: Track without intro")
		transition.request_play_transition(self,
		loops_audio_streams[loop_index], fade_in)
			
func on_play_loop(fade_time, loop_index):
	if loop_index > loops_audio_streams.size() - 1:
		AudioManager.debug._print("DEBUG: Not found loop index")
		return
		
	sec_per_beat = 60.0 / loop_files[loop_index].bpm
	loop_playing = loop_index
	transition.request_play_transition(self,
	loops_audio_streams[loop_index], fade_time)
	
func change_loop(index, fade_in, fade_out):
	can_end_track = false #evita el outro retrasado.
	
	fade_in_loop = fade_in
	fade_out_loop = fade_out
	loops_audio_streams[index].volume_db = volume_db
	if tween:
		tween.kill()
	
	if loop_files[loop_playing].keys_loop_in_beat != [] \
	or loop_files[loop_playing].keys_loop_in_measure != []:
		
		var audio_playing = get_stream_playing()
		
		if loop_playing != index:
			if audio_playing != outro_player and audio_playing != intro_player:
				loop_target = index
				can_change_track = true
				AudioManager.debug._print("DEBUG: Loop prepare to change")
			else:
				transition.request_change_transition(self, audio_playing,
				loops_audio_streams[index], fade_out, fade_in)
				AudioManager.debug._print("DEBUG: Go to the loop")
		else:
			can_change_track = false
			AudioManager.debug._print("DEBUG: Loop continue")
			
	else:
		if loop_playing != index:
			loop_target = index
			change_track(fade_out, fade_in)
		else:
			AudioManager.debug._print("DEBUG: Loop continue")
	
func on_outro(fade_out, fade_in):
	fade_in_loop = fade_in
	fade_out_loop = fade_out
	
	if outro_file != null:
		if loop_files[loop_playing].keys_end_in_beat != [] \
		or loop_files[loop_playing].keys_end_in_measure != []:
			
			if outro_player.playing:
				can_end_track = false
				AudioManager.debug._print("DEBUG: Outro continue")
			else:
				can_end_track = true
				AudioManager.debug._print("DEBUG: Outro prepare to change")
				
		else:
			var audio_playing = get_stream_playing()
			transition.request_change_transition(self, audio_playing,
			outro_player, fade_out, fade_in)
			outro_player.play()
			AudioManager.debug._print("DEBUG: Go to the outro")
	else:
		if outro_player.playing:
			AudioManager.debug._print("DEBUG: Outro continue")
		else:
			on_stop(fade_out)
	
func on_stop(fade_out):
	if fade_out != 0.0:
		for i in get_children():
			transition.fade_out(self, i, fade_out)
	else:
		destroy_track()
	
func intro_finished():
	loops_audio_streams[loop_playing].play()
	
func can_loop():
	if loop_files[loop_playing].loop:
		measures = 1
		beat_measure_count = 2
		last_reported_beat = 0
		song_position_in_beats = 0
		loops_audio_streams[loop_playing].play()
	
func _physics_process(delta):
	if loop_files != []:
		if loops_audio_streams[loop_playing].playing:
			song_position = loops_audio_streams[loop_playing].get_playback_position()\
			+ AudioServer.get_time_since_last_mix()
			
			song_position -= AudioServer.get_output_latency()
			song_position_in_beats = int(floor(song_position / sec_per_beat)) + beats_before_start
			_report_beat()

func _report_beat():
	if last_reported_beat < song_position_in_beats:
		if beat_measure_count > loop_files[loop_playing].metric:
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
	## Change Loops by Keys ##
	if loop_files[loop_playing].keys_loop_in_measure.has(measures) \
	and can_change_track:
		change_track()
		
	## Change to End by Keys ##
	if loop_files[loop_playing].keys_end_in_measure.has(measures) \
	and can_end_track:
		can_end_track = false
		var audio_playing = get_stream_playing()
		transition.request_change_transition(self, audio_playing,
		outro_player, fade_out_loop, fade_in_loop)
		outro_player.play()
		
func change_beat_tracks():
	## Change Loops by Keys ##
	if loop_files[loop_playing].keys_loop_in_beat.has(song_position_in_beats + 1) \
	and can_change_track:
		change_track()
		
	## Change to End by Keys ##
	if loop_files[loop_playing].keys_end_in_beat.has(song_position_in_beats + 1) \
	and can_end_track:
		can_end_track = false
		var audio_playing = get_stream_playing()
		transition.request_change_transition(self, audio_playing,
		outro_player, fade_out_loop, fade_in_loop)
		outro_player.play()
	
func change_track(fade_out = fade_out_loop, fade_in = fade_in_loop):
	can_change_track = false
	measures = 1
	last_reported_beat = 0
	song_position_in_beats = 0
	
	sec_per_beat = 60.0 / loop_files[loop_target].bpm
	transition.request_change_transition(self, loops_audio_streams[loop_playing],
	loops_audio_streams[loop_target], fade_out, fade_in)
	
	loops_audio_streams[loop_target].play()
	loop_playing = loop_target
	
	AudioManager.debug._print("DEBUG: Change Loop")
	
func destroy_track():
	for i in get_children():
		i.stop()
		
	queue_free()

func get_stream_playing():
	var childs = get_children()
	for i in childs:
		if i.playing:
			return i
			
	return null
