class_name EnemyProjectile
extends Area2D

var direction: Vector2 = Vector2.ZERO
var speed: float = 200.0

func set_direction(new_direction: Vector2) -> void:
	direction = new_direction

func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta
