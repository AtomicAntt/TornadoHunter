extends Area2D

@export var speed: float = 450
@export var steer_force = 80

var velocity: Vector2 = Vector2.ZERO
var acceleration: Vector2 = Vector2.ZERO
var target: Area2D = null

var direction: Vector2 = Vector2.ZERO

func start(set_direction: Vector2) -> void:
	velocity = direction * speed
	if len(get_tree().get_nodes_in_group("Boss")) > 0 or len(get_tree().get_nodes_in_group("Minion")) > 0:
		target = return_closest_enemy()

func seek() -> Vector2:
	var steer: Vector2 = Vector2.ZERO
	if target and is_instance_valid(target):
		var desired = (target.position - position).normalized() * speed
		steer = (desired - velocity).normalized * steer_force
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
	
	for minion: Minion in get_tree().get_nodes_in_group("Boss"):
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
