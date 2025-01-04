extends Area2D

@export var item: PackedScene

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("PlayerHitbox"):
		var player: Player = get_tree().get_nodes_in_group("Player")[0]
		if is_instance_valid(player):
			var item_instance: Area2D = item.instantiate()
			player.add_item_orbit(item_instance)
			queue_free()
	
