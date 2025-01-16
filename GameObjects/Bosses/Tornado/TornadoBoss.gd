extends Boss

var spinning_wind: Resource = preload("res://GameObjects/Bosses/Tornado/SpinningWind.tscn")
var wind_attack: Resource = preload("res://GameObjects/Bosses/Tornado/TornadoWind.tscn")

var attack_cooldown: float = 2.0
var attack_time: float = 0.0

func _physics_process(delta: float) -> void:
	match state:
		States.IDLE:
			pass
		States.CHARGING:
			attack_time += delta
			if attack_time >= attack_cooldown:
				attack_time = 0.0
				shoot_spinning_wind()
			
func _on_intro_timeout() -> void:
	state = States.CHARGING

func shoot_spinning_wind() -> void:
	var player: Player = get_tree().get_nodes_in_group("Player")[0]
	var direction_to_player: Vector2 = global_position.direction_to(player.global_position)
	
	var wind_instance: SpinningWind = spinning_wind.instantiate()
	wind_instance.set_direction(direction_to_player)
	wind_instance.global_position = global_position
	get_parent().call_deferred("add_child", wind_instance)
