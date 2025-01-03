extends CharacterBody2D

enum States {NORMAL, DEAD}
var state: States = States.NORMAL

@export var SPEED = 200.0

func _physics_process(delta: float) -> void:
	move_and_slide()
	
	match state:
		States.NORMAL:
			get_basic_movement()
		States.DEAD:
			velocity = Vector2.ZERO

func get_basic_movement() -> void:
	velocity = Vector2.ZERO
	
	if Input.is_action_pressed("right"):
		velocity.x = 1
	if Input.is_action_pressed("left"):
		velocity.x = -1
	if Input.is_action_pressed("up"):
		velocity.y = -1
	if Input.is_action_pressed("down"):
		velocity.y = 1
	
	velocity = velocity * SPEED
