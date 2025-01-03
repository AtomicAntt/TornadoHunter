class_name Boss
extends Area2D

@onready var max_health: float = 100.0
@onready var health: float = 100.0

var enemy_projectile: Resource = preload("res://GameObjects/Bosses/EnemyProjectile.tscn")

func hurt(damage: float) -> void:
	health -= damage
	for bossHealth: BossHealth in get_tree().get_nodes_in_group("BossHealthBar"):
		bossHealth.change_health(max_health, health)

func fire_at_player() -> void:
	var player: Player = get_tree().get_nodes_in_group("Player")[0]
	if is_instance_valid(player):
		var projectile_instance: EnemyProjectile = enemy_projectile.instantiate()
		projectile_instance.set_direction(global_position.direction_to(player.global_position))
		projectile_instance.global_position = global_position
		get_parent().add_child(projectile_instance)
		

func _on_timer_timeout() -> void:
	fire_at_player()
