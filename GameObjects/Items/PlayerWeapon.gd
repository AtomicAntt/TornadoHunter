extends Area2D

@export var damage: float = 10.0

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Boss"):
		var boss: Boss = area
		boss.hurt(damage)
