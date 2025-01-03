class_name Player
extends CharacterBody2D

enum States {NORMAL, DEAD, DASHING}
var state: States = States.NORMAL

@export var SPEED: float = 200.0

func _physics_process(delta: float) -> void:
	move_and_slide()
	
	match state:
		States.NORMAL:
			get_basic_movement()
			look_at_position(velocity.normalized())
			check_dash()
		States.DEAD:
			velocity = Vector2.ZERO
		States.DASHING:
			# This is called, however, it normally transitions out when the roll animation is finished.
			if !$AnimatedSprite2D.animation == "Roll":
				state = States.NORMAL
				velocity = Vector2.ZERO
				
			# By the time the rolling animation is halfway through, the distance is already traveled visually in the animation, so no more velocity.
			if $AnimatedSprite2D.frame >= 9:
				velocity = Vector2.ZERO
				get_basic_movement()
				if velocity.length() > 0: # Looks like the player started moving after checking their input! Lets get them back to normal state.
					state = States.NORMAL
			

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
	
	if state != States.DASHING:
		if velocity.length() > 0.0:
			$AnimatedSprite2D.play("Run")
		else:
			$AnimatedSprite2D.play("Idle")
	
	velocity = velocity.normalized() * SPEED

func look_at_position(pos: Vector2) -> void:
	#var pos: Vector2 = get_local_mouse_position()
	if pos.x < 0.0:
		$AnimatedSprite2D.flip_h = true
	else:
		$AnimatedSprite2D.flip_h = false

func check_dash() -> void:
	if Input.is_action_just_pressed("dash") && velocity.length() > 0.0:
		velocity = velocity.normalized() * SPEED * 2
		$AnimatedSprite2D.play("Roll")
		look_at_position(velocity.normalized())
		state = States.DASHING

func _on_animated_sprite_2d_animation_finished() -> void:
	if $AnimatedSprite2D.animation == "Roll":
		state = States.NORMAL
		velocity = Vector2.ZERO
		print("yow")
		
