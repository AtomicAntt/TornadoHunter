class_name Coin
extends Pickup

var value: int = 0

func _physics_process(delta: float) -> void:
	moveTowardsPlayer(delta)

func set_value(setValue: int) -> void:
	value = setValue

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("PlayerHitbox"):
		var player: Player = get_tree().get_nodes_in_group("Player")[0]
		player.get_coin()
		Global.add_gold(value)
		queue_free()
