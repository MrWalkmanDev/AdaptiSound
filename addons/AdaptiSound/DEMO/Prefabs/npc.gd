extends AnimatedSprite2D

var can_interact = false
var mouse_entered = false

func _input(_event):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and can_interact and mouse_entered:
		$Panel.visible = true
		get_parent().get_parent()._on_button_pressed()
		

func _on_area_2d_body_entered(_body):
	can_interact = true


func _on_area_2d_body_exited(_body):
	can_interact = false
	$Panel.visible = false


func _on_interact_mouse_entered():
	mouse_entered = true


func _on_interact_mouse_exited():
	mouse_entered = false
