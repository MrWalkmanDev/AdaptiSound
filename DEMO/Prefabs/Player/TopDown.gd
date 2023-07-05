extends CharacterBody2D

@export var max_speed = 50.0

var input_vector = Vector2.ZERO
var direction = "right"
var rng = RandomNumberGenerator.new()

@onready var animationPlayer = get_node("AnimatedSprite2D")

func _ready() -> void:
	pass
	
func _physics_process(delta):
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		update_direction(input_vector.x)
		velocity = velocity.move_toward(input_vector * max_speed, 1000 * delta)
		animationPlayer.play("run_right")
	else:
		velocity = velocity.move_toward(Vector2.ZERO * max_speed, 1000 * delta)
		animationPlayer.play("idle_right")
		update_direction(input_vector.x)
		
	move()
	
func move():
	move_and_slide()

func update_direction(input_direction_x) -> void:
	if input_direction_x > 0:
		set_direction_right()
	elif input_direction_x < 0:
		set_direction_left()

func set_direction_right() -> void:
	direction = "right"
	animationPlayer.flip_h = false

func set_direction_left() -> void:
	direction = "left"
	animationPlayer.flip_h = true

