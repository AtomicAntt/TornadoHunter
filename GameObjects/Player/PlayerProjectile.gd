class_name PlayerProjectile
extends Area2D

@export var speed: float = 200
@export var steer_force: float = 10
@export var damage: float = 5
@export var spinning: bool = false
@export var rotation_speed: float = 0.0
@export var rotating: bool = false # DIFFERENT FROM SPINNING, it means looking at the direction it is going.

var velocity: Vector2 = Vector2.ZERO
var acceleration: Vector2 = Vector2.ZERO
var target: Area2D = null

#var direction: Vector2 = Vector2.ZERO

func start(set_direction: Vector2) -> void:
	velocity = set_direction * speed
	
	if is_instance_valid("Boss"):
		if len(get_tree().get_nodes_in_group("Boss")) > 0:
			target = return_closest_enemy()

func seek() -> Vector2:
	var steer: Vector2 = Vector2.ZERO
	if target and is_instance_valid(target):
		var desired = (target.position - position).normalized() * speed
		steer = (desired - velocity).normalized() * steer_force
	elif len(get_tree().get_nodes_in_group("Boss")) > 0 or len(get_tree().get_nodes_in_group("Minion")) > 0:
		target = return_closest_enemy()
	return steer

func return_closest_enemy() -> Area2D:
	var dist: float = INF
	var closest_enemy: Area2D = null
	
	for boss: Boss in get_tree().get_nodes_in_group("Boss"):
		var enemy_distance = boss.global_position.distance_to(global_position)
		if enemy_distance < dist:
			closest_enemy = boss
			dist = enemy_distance
	
	for minion: Minion in get_tree().get_nodes_in_group("Minion"):
		var enemy_distance = minion.global_position.distance_to(global_position)
		if enemy_distance < dist:
			closest_enemy = minion
			dist = enemy_distance
	
	return closest_enemy

func _physics_process(delta: float) -> void:
	acceleration += seek()
	velocity += acceleration * delta
	velocity = velocity.limit_length(speed)
	position += velocity * delta
	
	if rotating:
		rotation = velocity.angle()
	
	if spinning:
		var new_rotation = rotation_degrees + rotation_speed * delta
		rotation_degrees = fmod(new_rotation, 360)

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Boss"):
		var boss: Boss = area
		boss.hurt(damage)
		queue_free()
	elif area.is_in_group("Minion"):
		var minion: Minion = area
		minion.hurt(damage)
		queue_free()

func _on_expiration_timer_timeout() -> void:
	queue_free()
