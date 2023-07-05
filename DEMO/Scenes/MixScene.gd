extends Node2D

# AdaptiveTrack Structure #
func _on_intro_pressed():
	AudioManager.play_music("BossMusic")

func _on_loop_1_pressed():
	AudioManager.change_loop("BossMusic", 0)

# ParallelTrack #
func _on_loop_2_pressed():
	AudioManager.change_loop("BossMusic", 1)

func _on_layer_1_toggled(button_pressed):
	if button_pressed:
		AudioManager.layer_on("BossMusic", ["Staccato"])
	else:
		AudioManager.layer_off("BossMusic", ["Staccato"])


func _on_layer_2_toggled(button_pressed):
	if button_pressed:
		AudioManager.layer_on("BossMusic", ["Mid"], 0.65)
	else:
		AudioManager.layer_off("BossMusic", ["Mid"])


func _on_layer_3_toggled(button_pressed):
	if button_pressed:
		AudioManager.layer_on("BossMusic", ["Top"], 0.75)
	else:
		AudioManager.layer_off("BossMusic", ["Top"])


# AdaptiveTrack Outro#
func _on_outro_pressed():
	AudioManager.to_outro("BossMusic")
