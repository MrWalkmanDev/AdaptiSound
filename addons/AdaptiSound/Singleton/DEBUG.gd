extends Node

#class_name DEBUG

func _print(value):
	if AudioManager.debugging:
		print(value)
