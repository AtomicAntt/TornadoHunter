extends Area2D

var player: Player

func _ready() -> void:
	player = get_tree().get_nodes_in_group("Player")[0]

func _physics_process(delta: float) -> void:
	if is_instance_valid(player):
		if global_position.direction_to(player.global_position).x < 0:
			$AnimatedSprite2D.flip_h = true
		else:
			$AnimatedSprite2D.flip_h = false
	else:
		player = get_tree().get_nodes_in_group("Player")[0]
