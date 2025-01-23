extends Area2D

@export var damage: float = 2.5

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Boss"):
		var boss: Boss = area
		boss.hurt(damage)
	elif area.is_in_group("Minion"):
		var minion: Minion = area
		minion.hurt(damage)
		
		#var camera_shaker: CameraShaker = get_tree().get_nodes_in_group("Camera")[0]
		#if is_instance_valid(camera_shaker):
			#camera_shaker.apply_super_weak_shake()
