extends Node

class_name AudioTransitions

func underwater_effect(bus):
	var filter = AudioEffectLowPassFilter.new()
	var bus_index = AudioServer.get_bus_index(bus)
	AudioServer.add_bus_effect(bus_index, filter, AudioServer.get_bus_effect_count(bus_index))
	print(AudioServer.get_bus_effect_count(bus_index))
	#var tween = create_tween()
	#tween.tween_property(effect, "cutoff_hz", 800, 2.0)
