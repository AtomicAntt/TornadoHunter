class_name EnemyProjectile
extends Area2D

var direction: Vector2 = Vector2.ZERO
var speed: float = 200.0

func set_direction(new_direction: Vector2) -> void:
	direction = new_direction

func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("PlayerHitbox"):
		var player = get_tree().get_nodes_in_group("Player")[0]
		if is_instance_valid(player):
			player.hurt(1)
		
