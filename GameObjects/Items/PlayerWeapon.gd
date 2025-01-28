extends Area2D

enum Weapons {NONE, TUMBLEWEED, TORNADO, CLOCK}
@export var weapon: Weapons = Weapons.NONE

@export var damage: float = 2.5

var player_tumbleweed: Resource = preload("res://GameObjects/Player/PlayerTumbleweed.tscn")
var player_wind: Resource = preload("res://GameObjects/Player/PlayerWind.tscn")

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Boss"):
		var boss: Boss = area
		boss.hurt(damage)
	elif area.is_in_group("Minion"):
		var minion: Minion = area
		minion.hurt(damage)
	elif area.is_in_group("WeaponActivator"):
		activate_ability()
		
		#var camera_shaker: CameraShaker = get_tree().get_nodes_in_group("Camera")[0]
		#if is_instance_valid(camera_shaker):
			#camera_shaker.apply_super_weak_shake()

func activate_ability() -> void:
	match weapon:
		Weapons.TUMBLEWEED:
			var main: Main = get_tree().get_nodes_in_group("Main")[0]
			var projectile_instance: PlayerProjectile = player_tumbleweed.instantiate()
			projectile_instance.start(global_position.direction_to(get_global_mouse_position()))
			projectile_instance.global_position = global_position
			
			main.level_instance.call_deferred("add_child", projectile_instance)
			$Spawn.play()
		Weapons.TORNADO:
			var main: Main = get_tree().get_nodes_in_group("Main")[0]
			var projectile_instance: PlayerProjectile = player_wind.instantiate()
			projectile_instance.start(global_position.direction_to(get_global_mouse_position()))
			projectile_instance.global_position = global_position
			
			main.level_instance.call_deferred("add_child", projectile_instance)
			$Spawn.play()
		Weapons.CLOCK:
			pass
