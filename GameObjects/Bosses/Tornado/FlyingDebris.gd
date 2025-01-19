class_name FlyingDebris
extends EnemyProjectile

@export var velocity: float = 150

var target: SpinningWind
#var boss: Boss

var sprite_name: String

var friction_enabled: bool = false # If it is enabled, no need to count it as flying debris that still needs to be collected in order for the boss to attack.

func _ready() -> void:
	#if is_instance_valid(get_tree().get_nodes_in_group("Player")[0]):
		#boss = get_tree().get_nodes_in_group("Boss")[0]
	
	var sprite_names: Array[String] = ["Arrow", "CannonBall", "Rock", "Shuriken"]
	sprite_name = sprite_names.pick_random()
	
	$AnimatedSprite2D.play(sprite_name)


#func _physics_process(delta: float) -> void:
	#if not friction_enabled:
		#global_position = global_position.move_toward(target.global_position, velocity * delta)
	#else:
		#global_position += direction * speed * delta
		#speed -= friction * delta
		#speed = clampf(speed, 0.0, max_speed)
	#
	#if spinning:
		#var new_rotation = rotation_degrees + rotation_speed * delta
		#rotation_degrees = fmod(new_rotation, 360)
	#
	#if get_tree().get_node_count_in_group("Boss") <= 0 and !dissolving:
		#dissolving = true
		#dissolve()
func _process(delta: float) -> void:
	if is_instance_valid(target) and not friction_enabled:
		if target.accumulated_debris >= target.max_capacity:
			enable_friction()

func enable_friction() -> void:
	friction_enabled = true
	#set_speed(randf_range(30.0, 60.0))
	set_friction(randf_range(80.0, 100.0))
	spinning = false
	
	acceleration = 0
	
	remove_from_group("Debris")
