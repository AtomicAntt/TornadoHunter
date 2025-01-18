class_name FlyingDebris
extends Area2D

@export var velocity: float = 120
var boss: Boss

var sprite_name: String

func _ready() -> void:
	if is_instance_valid(get_tree().get_nodes_in_group("Player")[0]):
		boss = get_tree().get_nodes_in_group("Boss")[0]
	
	var sprite_names: Array[String] = ["Arrow", "CannonBall", "Rock", "Shuriken"]
	sprite_name = sprite_names.pick_random()
	
	$AnimatedSprite2D.play(sprite_name)

func _physics_process(delta: float) -> void:
	global_position = global_position.move_toward(boss.global_position, velocity * delta)
