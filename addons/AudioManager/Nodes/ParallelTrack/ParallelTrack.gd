extends Node

@export var layers : Array[NodePath]

var nodes = []

func _ready():
	for i in layers:
		var node = get_node_or_null(i)
		if node != null:
			nodes.append(node)
		
	on_play()
	
func on_play():
	for i in nodes:
		if i.type == "Always":
			i.on_play()
