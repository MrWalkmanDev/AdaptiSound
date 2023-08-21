extends CharacterBody2D

@export var objetive : CharacterBody2D

@export var speed = 5.0

enum state {
	idle,
	chase
}
var current_state

var can_destroy = false

func _ready():
	current_state = state.idle
	objetive = get_tree().get_nodes_in_group("Player")[0]
	
func _input(event):
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		if can_destroy:
			queue_free()
	
func _process(delta):
	var point = objetive.position - self.position
	point = point.normalized()
	
	match current_state:
		state.idle: 
			velocity = velocity.move_toward(Vector2.ZERO, 500 * delta)
		state.chase: 
			velocity = velocity.move_toward(point * speed, 500 * delta)
			
	move_and_slide()

func _on_sight_body_entered(body):
	if body.name == "Player":
		current_state= state.chase

func _on_sight_body_exited(body):
	if body.name == "Player":
		current_state= state.idle

func _on_hurt_box_mouse_entered():
	can_destroy = true


func _on_hurt_box_mouse_exited():
	can_destroy = false
