extends Area2D

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("EnemyAttack"):
		var enemyAttack: EnemyProjectile = area
		area.queue_free()
		queue_free()
