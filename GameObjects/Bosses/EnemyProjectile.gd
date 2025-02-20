class_name EnemyProjectile
extends Area2D

var direction: Vector2 = Vector2.ZERO
@export var max_speed: float = 200.0
@export var speed: float = 200.0
@export var friction: float = 0.0
@export var rotation_speed: float = 0.0
@export var acceleration: float = 0.0

@export var static_projectile: bool = false
@export var spinning: bool = false

@export var damage: int = 1

var dissolving: bool = false

func set_direction(new_direction: Vector2) -> void:
	direction = new_direction

func set_friction(new_friction: float) -> void:
	friction = new_friction

func set_speed(new_speed: float) -> void:
	speed = new_speed
	max_speed = new_speed

func set_time(new_time: float) -> void:
	$ExpirationTimer.wait_time = new_time

func _physics_process(delta: float) -> void:
	var _delta: float = delta * Global.time_scale
	global_position += direction * speed * _delta
	speed -= friction * _delta
	speed += acceleration * _delta
	speed = clampf(speed, 0.0, max_speed)
	
	if spinning:
		var new_rotation = rotation_degrees + rotation_speed * _delta
		rotation_degrees = fmod(new_rotation, 360)
	
	if get_tree().get_node_count_in_group("Boss") <= 0 and !dissolving:
		dissolving = true
		dissolve()
	
	if speed <= 0 and !static_projectile:
		if has_overlapping_bodies():
			# Why did I do this? Sometimes the player is invulnerable and thus projectiles passing through their physics body should not disappear.
			var player: Player = get_tree().get_nodes_in_group("Player")[0]
			if !overlaps_body(player):
				#queue_free()
				dissolve()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("PlayerHitbox") and !dissolving:
		var player: Player = get_tree().get_nodes_in_group("Player")[0]
		if is_instance_valid(player):
			# Why do this if hurting player won't work if they are invulnerable anyway? So that the projectile does not disappear when entering their hitbox while they are invulnerable.
			if !player.is_invulnerable():
				player.hurt(damage)
				queue_free()

func _on_expiration_timer_timeout() -> void:
	#queue_free()
	dissolve()

# Animation player will queue_free() it afterwards.
func dissolve() -> void:
	dissolving = true
	$AnimationPlayer.play("Dissolve")
