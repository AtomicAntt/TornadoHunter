class_name EnemyProjectile
extends Area2D

var direction: Vector2 = Vector2.ZERO
var max_speed: float = 200.0
var speed: float = 200.0
var friction: float = 0.0

func set_direction(new_direction: Vector2) -> void:
	direction = new_direction

func set_friction(new_friction: float) -> void:
	friction = new_friction

func set_speed(new_speed: float) -> void:
	speed = new_speed
	max_speed = new_speed

func set_time(new_time: float) -> void:
	$Timer.stop()
	$Timer.wait_time = new_time
	$Timer.start()

func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta
	speed -= friction * delta
	speed = clampf(speed, 0.0, max_speed)
	
	if speed <= 0:
		if has_overlapping_bodies():
			queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("PlayerHitbox"):
		var player = get_tree().get_nodes_in_group("Player")[0]
		if is_instance_valid(player):
			player.hurt(1)
			queue_free()

func _on_expiration_timer_timeout() -> void:
	queue_free()
