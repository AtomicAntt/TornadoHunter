extends CharacterBody2D

enum States {NORMAL, DEAD}
var state: States = States.NORMAL

@export var SPEED: float = 150.0

func _physics_process(delta: float) -> void:
	move_and_slide()
	
	match state:
		States.NORMAL:
			get_basic_movement()
			look_at_mouse()
			
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
	
	if velocity.length() > 0.0:
		$AnimatedSprite2D.play("Run")
	else:
		$AnimatedSprite2D.play("Idle")
	
	velocity = velocity * SPEED

func look_at_mouse() -> void:
	var pos: Vector2 = get_local_mouse_position()
	if pos.x < 0.0:
		$AnimatedSprite2D.flip_h = true
	else:
		$AnimatedSprite2D.flip_h = false
