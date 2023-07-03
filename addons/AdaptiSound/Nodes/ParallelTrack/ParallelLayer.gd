extends AdaptiNode

const AUDIO = preload("res://addons/AdaptiSound/Nodes/ParallelTrack/Audio_Stream.tscn")

## Choose the type of layer 
##[br][b]Always[/b]: Plays when calling [b]on_play()[/b]
##[br][b]Trigger[/b]: Is playing with a specific command
@export_enum("Always", "Trigger") var playing_type : String = "Always"

## Choose the number of tracks that will be played on this layer
@export var audio_streams : Array[AudioStream]

## If false, it will not be heard when calling [b]on_play()[/b]
@export var layer_on = true

## Choose if the layer is a loop
@export var loop = true

## Select group of layer
@export_group("Groups")
@export var groups : Array[String]

#var volume_db : float = 0.0 : set = set_volume_db, get = get_volume_db
#var pitch_scale : float = 1.0 : set = set_pitch_scale, get = get_pitch_scale

var tween
var can_change = true

func _ready():
	#connect("finished", to_loop) 
	
	if audio_streams != []:
		for i in audio_streams:
			var audio_stream = AUDIO.instantiate()
			audio_stream.name = self.name
			audio_stream.loop = loop
			audio_stream.stream = i
			add_child(audio_stream)
			
"""func _process(delta):
	if stream != null and self.playing:
		if(self.stream.get_length() - self.get_playback_position()) <= 0.01 and can_change:
			can_change = false
			to_loop()

func to_loop():
	if can_loop:
		can_change = true
		play()"""

func on_play(fade_time, volume):
	if get_child_count() > 0: 
		for i in get_children():
			if fade_time != 0.0:
				i.volume_db = -50.0
				i.play()
				change(volume, fade_time)
			else:
				i.volume_db = volume
				i.play()
	else:
		AudioManager.debug._print("DEBUG: No tracks in " + str(self.name))

func change(volume, fade_time, fade_type := true, can_stop := true):
	if fade_type:
		if get_child_count() > 0:
			for i in get_children():
				if fade_time != 0.0:
					i.on_fade_in(volume, fade_time)
				else:
					i.volume_db = volume
					#i.play()
		else:
			AudioManager.debug._print("DEBUG: No tracks in " + str(self.name))
	else:
		if get_child_count() > 0:
			for i in get_children():
				if fade_time != 0.0:
					i.on_fade_out(fade_time, can_stop)
				else:
					if can_stop:
						i.stop()
					else:
						i.volume_db = -50.0
		else:
			AudioManager.debug._print("DEBUG: No tracks in " + str(self.name))



	#########################
	## SETTERS AND GETTERS ##
	#########################

"""func set_volume_db(value):
	volume_db = value
	for i in get_children():
		i.volume_db = value
	
func get_volume_db():
	return volume_db
	
func set_pitch_scale(value):
	pitch_scale = value
	for i in get_children():
		for n in i.get_children():
			n.pitch_scale = pitch_scale
			
		i.pitch_scale = pitch_scale
	
func get_pitch_scale():
	return pitch_scale"""
