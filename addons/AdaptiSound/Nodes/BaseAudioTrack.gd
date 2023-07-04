extends Resource

class_name BaseAudioTrack

## Audio File
@export_file var audio_file
## Name with the loop will be called (Node name instance)
@export var track_name : String
## Beat per Minutes.
@export var bpm := 120.0
## Metric of Track, for example (3/4 = 3), (6/8 = 6), (4/4 = 4).
@export var metric := 4
## If track is loopeable or not.
@export var loop = true
## Total beats of the track, this variable is needed for the loop.
@export var total_beat_count : int

@export_category("Loop Keys Values")
# Points where the loop can transition to another Loop. Use Beats Count
#@export var keys_loop_in_beat : Array[int]
## Points where the loop can transition to another Loop. Use Measure Count
@export var keys_loop_in_measure : Array[int]

# Points where the loop can transition to Outro. Use Beats Count
#@export var keys_end_in_beat : Array[int]
## Points where the loop can transition to Outro. Use Measure Count
@export var keys_end_in_measure : Array[int]
