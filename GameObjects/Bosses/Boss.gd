class_name Boss
extends Area2D

@onready var max_health: float = 100.0
@onready var health: float = 100.0

func hurt(damage: float) -> void:
	health -= damage
	for bossHealth: BossHealth in get_tree().get_nodes_in_group("BossHealthBar"):
		bossHealth.change_health(max_health, health)
