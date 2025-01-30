@tool
extends Control

@onready var vbox = $HBoxContainer/VBoxContainer
@onready var audio_preview = $HBoxContainer/VBoxContainer/GridContainer/VBoxContainer/HSlider

var node_selected : AdaptiNode

func initialize_panel(selection:AdaptiNode):
	node_selected = selection
	#var track : AudioStreamPlayer = node_selected.audio_players[node_selected.audio_players.keys()[0]]
	#print(audio_preview.max_value)
	print(node_selected.layers[0].clip.get_length())
	audio_preview.max_value = node_selected.layers[0].clip.get_length()
	
	#print(selection.layers)
	#for i in vbox.get_children():
	#	i.queue_free()
		
	#for i in 20:
		#var but = Button.new()
		#but.size_flags_horizontal = SIZE_EXPAND_FILL
		#but.text = "Button"
		#vbox.add_child(but)
	


func _on_play_pressed():
	node_selected.play()
