extends Node

var volume_db = 0.0
var layers = []

func _input(event):
	if Input.is_action_just_pressed("ui_up"):
		on_layers(["Drums"])
		
	if Input.is_action_just_pressed("ui_down"):
		off_layers(["Drums"])

func _ready():
	for i in get_children():
		#var node = get_node_or_null(i)
		#if node != null:
		layers.append(i)
		
	on_play()
	
func on_play():
	for i in layers:
		if i.type == "Always" and i.play_on_start:
			i.on_play()

func on_layers(layers_names : PackedStringArray, fade_in := 2.0):
	for i in layers_names:
		var node = get_layer(i)
		node.on_fade_in(fade_in)
	
func off_layers(layers_names : PackedStringArray, fade_out := 2.0):
	for i in layers_names:
		var node = get_layer(i)
		node.on_fade_out(fade_out)
		


func get_layer(layer_name):
	var childrens = get_children()
	for i in childrens:
		if i.name == layer_name:
			return i
	
