class_name FlyingDebris
extends EnemyProjectile

@export var velocity: float = 150

var target: Node2D
#var boss: Boss

var sprite_name: String

func _ready() -> void:
	#if is_instance_valid(get_tree().get_nodes_in_group("Player")[0]):
		#boss = get_tree().get_nodes_in_group("Boss")[0]
	
	var sprite_names: Array[String] = ["Arrow", "CannonBall", "Rock", "Shuriken"]
	sprite_name = sprite_names.pick_random()
	
	$AnimatedSprite2D.play(sprite_name)


func _physics_process(delta: float) -> void:
	global_position = global_position.move_toward(target.global_position, velocity * delta)
	
	if spinning:
		var new_rotation = rotation_degrees + rotation_speed * delta
		rotation_degrees = fmod(new_rotation, 360)
	
	if get_tree().get_node_count_in_group("Boss") <= 0 and !dissolving:
		dissolving = true
		dissolve()
