extends AdaptiNode

#signal beat
signal measure
signal end_track

const AUDIOPLAYER = preload("res://addons/AdaptiSound/Nodes/ParallelTrack/Audio_Stream.tscn")

## Here you must assign the Audios, and Loops that belong to each section. Outro can be omitted.
@export_group("Assignments Track Section")
## This track is played only once when calling the [b]play_music()[/b] function.
@export var intro_file : AudioStream
## These are the tracks that can be looped. The first one will play automatically after the Intro.
@export var loop_files : Array[BaseAudioTrack]
## This track is played only once when calling the [b]end_music()[/b] function.
@export var outro_file : AudioStream

var current_playback #: AudioStreamPlayer

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
var loops = {}
var loops_audio_streams = []

# Fades
var fade_out_loop = 1.5
var fade_in_loop = 0.5

func _ready():
	intro_player = AUDIOPLAYER.instantiate()
	intro_player.set_bus(bus)
	intro_player.loop = false
	intro_player.stream = intro_file
	intro_player.volume_db = volume_db
	intro_player.name = "Intro"
	add_child(intro_player)
	intro_player.connect("finished", intro_finished)
	
	outro_player = AUDIOPLAYER.instantiate()
	outro_player.set_bus(bus)
	outro_player.loop = false
	outro_player.stream = outro_file
	outro_player.volume_db = -50.0 # Para la primera vez que se reproduce Outro (with Fade in)
	outro_player.name = "Outro"
	add_child(outro_player)
	#outro_player.connect("finished", on_stop.bind(0.0))
	
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
		if loops[n] is PackedScene:
			# For Parallel Tracks Added
			var audio_stream = loops[n].instantiate()
			audio_stream.bus = bus
			audio_stream.name = n 
			add_child(audio_stream)
			loops_audio_streams.append(get_node(audio_stream.get_path()))
		else:
			# For AudioStream Loop
			var index = loops.keys().find(n)
			var audio_stream = AUDIOPLAYER.instantiate()
			audio_stream.loop = loop_files[index].loop ## Define si es loop o no
			audio_stream.set_bus(bus)
			audio_stream.volume_db = -50.0 # Es para que la primera vez que ejecuta change_loop
			audio_stream.name = n
			audio_stream.stream = loops[n]
			add_child(audio_stream)
		
			loops_audio_streams.append(get_node(audio_stream.get_path()))


######################
## PLAYBACK OPTIONS ##
######################

func on_play(fade_in := 0.0, skip_intro := false, loop_index := 0):
	for i in get_children():
		if i != intro_player:
			if i is AudioStreamPlayer:
				i.on_fade_out(1.5)
			else:
				i.on_stop(1.5)
				
				
	if skip_intro:
		on_play_loop(fade_in, loop_index)
		return
	
	## Check if index is correct
	if loop_index > loops_audio_streams.size() - 1:
		AudioManager.debug._print("DEBUG: Not found loop index")
		return
	
	first_loop_playing = loop_index
	
	if intro_file != null:
		if not intro_player.is_connected("finished", intro_finished):
			intro_player.connect("finished", intro_finished)
			
		intro_player.volume_db = volume_db
		measures = 1  ## Need this for reset or stop sin destroy
		#reset_beat_parameters()
		if fade_in != 0.0:
			intro_player.volume_db = -50.0
			intro_player.on_fade_in(volume_db, fade_in)
			
		intro_player.play()
		current_playback = intro_player
	else:
		on_play_loop(fade_in, loop_index)
		AudioManager.debug._print("DEBUG: Track without intro")


func on_play_loop(fade_time := 0.0, loop_index := 0):
	for i in get_children():
		if i != loops_audio_streams[loop_index]:
			if i is AudioStreamPlayer:
				i.on_fade_out(1.5)
			else:
				i.on_stop(1.5)
	
	## Check if index is correct
	if loop_index > loops_audio_streams.size() - 1:
		AudioManager.debug._print("DEBUG: Not found loop index")
		return
	
	loops_audio_streams[loop_index].volume_db = volume_db ## Need this for reset play
	sec_per_beat = 60.0 / loop_files[loop_index].bpm
	if loops_audio_streams[loop_index] is AudioStreamPlayer:
		if fade_time != 0.0:
			loops_audio_streams[loop_index].volume_db = -50.0
		loops_audio_streams[loop_index].on_fade_in(volume_db, fade_time)
		loops_audio_streams[loop_index].play()
	else:
		loops_audio_streams[loop_index].on_fade_in(volume_db, fade_time)
		#loops_audio_streams[loop_index].on_play()
	AudioManager.debug._print("DEBUG: Skip intro")
	
	current_playback = loops_audio_streams[loop_index]
	reset_beat_parameters()


func change_loop(index, fade_in := 0.5, fade_out := 1.5):
	## Check if index is correct
	if index > loops_audio_streams.size() - 1:
		AudioManager.debug._print("DEBUG: Not found loop index")
		return
	
	## Verify if target loop is same loop
	if current_playback == loops_audio_streams[index]:
		can_change_track = false
		can_end_track = false
		AudioManager.debug._print("DEBUG: Loop continue")
		return
		
	can_end_track = false # Stop offset Outro change by key
	
	## Set fade_times values for change by key
	fade_in_loop = fade_in
	fade_out_loop = fade_out
	
	## Check if current_playback is a Loop
	var current_loop_index = loops_audio_streams.find(current_playback)
	
	if current_loop_index != -1:
		## Check if Loop has keys
		if loop_files[current_loop_index].keys_loop_in_measure != []:
			
			loop_target = index
			can_change_track = true
			AudioManager.debug._print("DEBUG: Loop prepare to change")
				
		else:
			## Inmediate Change Loop
			beat_measure_count = 1 ## only inmediate
			_beat = 0 # puede que no sea necesario
			loop_target = index
			change_track(current_playback, loops_audio_streams[index], fade_out, fade_in)
			AudioManager.debug._print("DEBUG: Change Loop")
	
	## Back to the loop from Outro
	if current_playback == outro_player:
		if outro_player.is_connected("finished", on_stop):
			outro_player.disconnect("finished", on_stop)
			
		beat_measure_count = 1 ## only inmediate
		change_track(outro_player, loops_audio_streams[index], fade_out, fade_in)
		AudioManager.debug._print("DEBUG: Outro to loop")



func on_outro(fade_out := 1.5, fade_in := 0.5):
	## Check if current playback is a loop
	if loops_audio_streams.has(current_playback) == false:
		can_end_track = false
		AudioManager.debug._print("DEBUG: Can change from intro or outro")
		return
	
	can_change_track = false # Stop offset Loop change by key
	
	## Set fade_times values for change by key
	fade_in_loop = fade_in
	fade_out_loop = fade_out
	
	var current_loop_index = loops_audio_streams.find(current_playback)
	
	if outro_file != null:
		if loop_files[current_loop_index].keys_end_in_measure != []:
			
			if not outro_player.is_connected("finished", on_stop):
				outro_player.connect("finished", on_stop.bind(0.0))
				
			can_end_track = true
			AudioManager.debug._print("DEBUG: Outro prepare to change")
				
		else:
			## Inmediate change to Outro
			if not outro_player.is_connected("finished", on_stop):
				outro_player.connect("finished", on_stop.bind(0.0))
				
			change_outro(fade_out, fade_in)
			AudioManager.debug._print("DEBUG: Go to the outro")
	else:
		## No outro file
		on_stop(fade_out)


func on_stop(fade_out := 0.0):
	if intro_player.is_connected("finished", intro_finished):
		intro_player.disconnect("finished", intro_finished)
	if outro_player.is_connected("finished", on_stop):
		outro_player.disconnect("finished", on_stop)
	
	if fade_out != 0.0:
		for i in get_children():
			i.on_fade_out(fade_out)
	else:
		for i in get_children():
			if i is AudioStreamPlayer:
				if i.tween:
					i.tween.kill()
				i.stop()
				
			## ParallelTrack or SecuenceTrack
			else:
				i.on_stop()
				
	emit_signal("end_track")
	
	current_playback = null
	
	## Por si no hay otras pistas reproduciendose
	if AudioManager.current_playback == self:
		AudioManager.current_playback = null



	#############
	## PROCESS ##
	#############
	
func intro_finished():
	## Check if is another AdaptiveNode
	if loops_audio_streams[first_loop_playing] is AudioStreamPlayer:
		loops_audio_streams[first_loop_playing].play()
		loops_audio_streams[first_loop_playing].volume_db = volume_db ## Need set volume for reset play
	else:
		loops_audio_streams[first_loop_playing].volume_db = volume_db
		loops_audio_streams[first_loop_playing].on_play()
	current_playback = loops_audio_streams[first_loop_playing]
	reset_beat_parameters()
	

func reset_beat_parameters():
	var current_loop_index = loops_audio_streams.find(current_playback)
	measures = 1 ## Antes no estaba
	beat_measure_count = 1
	last_reported_beat = 0
	song_position_in_beats = 0
	_beat = 0
	sec_per_beat = 60.0 / loop_files[current_loop_index].bpm
	
# Set Secuence
func set_secuence(sound_name: String):
	secuence.name = sound_name
	var track = AudioManager.add_track(sound_name)
	return track
	
## Measure and Beat Count
func _physics_process(delta):
	## Set Secuence
	if secuence != {}:
		if get_stream_playing() == null:
			AudioManager.play_music(secuence.name)
			secuence.clear()
			print("Secuence!")
			#emit_signal("end_track")
			
	
	## Beat Count ##
	if loop_files != []:
		if current_playback is AudioStreamPlayer:## Para combinar Parallel track
			if loops_audio_streams.has(current_playback):
				var current_loop_index = loops_audio_streams.find(current_playback)
			#if current_loop_index != -1:
				#if loops_audio_streams[current_loop_index].playing:
				if current_playback.playing:
					#song_position = loops_audio_streams[current_loop_index].get_playback_position()\
					#+ AudioServer.get_time_since_last_mix()
					song_position = current_playback.get_playback_position()\
					+ AudioServer.get_time_since_last_mix()
					
					song_position -= AudioServer.get_output_latency()
					song_position_in_beats = int(floor(song_position / sec_per_beat)) + beats_before_start
					
					#var total_song_position_in_beat = int(floor(current_playback.stream.get_length() / sec_per_beat))
					_report_beat(current_loop_index)

func _report_beat(current_loop_index):
	## First Beat (Loop)
	if song_position_in_beats <= 0 \
	and last_reported_beat == loop_files[current_loop_index].total_beat_count - 1 \
	and can_first_beat:
		can_first_beat = false
		_beat = 0
		beat_measure_count = 1
		measures = 1
		AudioManager.debug._print("DEBUG: Measure count: " + str(measures) + "Loop")
		change_measure_tracks()
	if _beat < song_position_in_beats:
		can_beat = true
	
	## Beat Report
	if can_beat:
		can_beat = false
		_beat += 1
		beat_measure_count += 1
		if beat_measure_count > loop_files[current_loop_index].metric:
			measures += 1
			beat_measure_count = 1
			can_first_beat = true
			change_measure_tracks()
			emit_signal("measure")
			AudioManager.debug._print("DEBUG: Measure count: " + str(measures))
		
		last_reported_beat = song_position_in_beats


func change_measure_tracks():
	var current_loop_index = loops_audio_streams.find(current_playback)
	## Change Loops by Keys ##
	if loop_files[current_loop_index].keys_loop_in_measure.has(measures) \
	and can_change_track:
		change_track(current_playback, loops_audio_streams[loop_target])
		return true
		
	## Change to End by Keys ##
	if loop_files[current_loop_index].keys_end_in_measure.has(measures) \
		and can_end_track:
		can_end_track = false
		change_outro(fade_out_loop, fade_in_loop)
		return true


func change_outro(fade_out, fade_in):
	outro_player.volume_db = volume_db
	
	for i in get_children():
		if i != outro_player and i != current_playback:
			if i is AudioStreamPlayer:
				i.stop()
			else:
				i.on_stop()
				
	current_playback.on_fade_out(fade_out)
	if fade_in != 0.0:
		outro_player.volume_db = -50.0
	outro_player.on_fade_in(volume_db, fade_in)
	outro_player.play()
	current_playback = outro_player
	
	
func change_track(from_track, to_track, fade_out = fade_out_loop, fade_in = fade_in_loop):
	var loop_index = loops_audio_streams.find(to_track)
	can_change_track = false
	measures = 1
	last_reported_beat = 0
	song_position_in_beats = 0
	_beat = 0
	sec_per_beat = 60.0 / loop_files[loop_index].bpm
	
	
	from_track.on_fade_out(fade_out)
	to_track.on_fade_in(volume_db, fade_in)
	
	if to_track is AudioStreamPlayer:
		to_track.play()
	
	current_playback = to_track



	#############################
	## FOR PARALLELTRACKS ADDS ##
	#############################
	
func on_layers(layer_names, fade_time):
	if not current_playback is AudioStreamPlayer and current_playback != null:
		current_playback.on_layers(layer_names, fade_time)
	
func off_layers(layer_names, fade_time):
	if not current_playback is AudioStreamPlayer and current_playback != null:
		current_playback.off_layers(layer_names, fade_time)
		
func play_layer(layer_names, fade_time):
	if not current_playback is AudioStreamPlayer and current_playback != null:
		current_playback.play_layer(layer_names, fade_time)
		
func stop_layer(layer_names, fade_time):
	if not current_playback is AudioStreamPlayer and current_playback != null:
		current_playback.stop_layer(layer_names, fade_time)
