class_name Player
extends CharacterBody2D

enum States {NORMAL, DEAD, DASHING}
var state: States = States.NORMAL

@export var SPEED: float = 200.0
@export var max_lives: int = 10
@export var lives: int = 10

var invulnerable: bool = false

func _physics_process(_delta: float) -> void:
	move_and_slide()
	
	match state:
		States.NORMAL:
			get_basic_movement()
			if velocity.length() > 0.0:
				look_at_position(velocity.normalized())
			check_dash()
			
			#if Input.is_action_pressed("fire"):
				#$AnimatedSprite2D.play("Turn")
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
	
	var speed_multiplier: float = 1.0
	
	#if Input.is_action_pressed("fire"):
		#$AnimatedSprite2D.play("Turn")
		#speed_multiplier = 0.4
		
	velocity = velocity.normalized() * SPEED * speed_multiplier

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

func add_item_orbit(item: Area2D):
	if item.is_in_group("weapon"):
		$Orbitor.call_deferred("add_child", item)
	elif item.is_in_group("shield"):
		$Orbitor2.call_deferred("add_child", item)
		
func hurt(damage: int):
	lives -= damage
	$AnimationPlayer.play("Hurt")
	$Hurt.play()
	
	var hearts_container: HeartsContainer = get_tree().get_nodes_in_group("HeartsContainer")[0]
	if is_instance_valid(hearts_container):
		hearts_container.update_hearts(lives)
	
	if lives <= 0:
		death()

func death():
	state = States.DEAD
