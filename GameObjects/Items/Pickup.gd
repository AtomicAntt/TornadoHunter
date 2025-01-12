class_name Pickup
extends Area2D

@export var explodeVelocity: float = 2000
@export var velocity: float = 120
@export var pickUpRange: float = 40000
@export var canMoveTowardsPlayer: bool = false

@export var explodeMinDistance: float = 5
@export var explodeMaxDistance: float = 30

var player: Player

func explode_outwards() -> void:
	var randomPositionOffsetX: float = randf_range(explodeMinDistance, explodeMaxDistance)
	var randomPositionOffsetY: float = randf_range(explodeMinDistance, explodeMaxDistance)
	if randi() % 2 + 1 == 1:
		randomPositionOffsetX *= -1
		
	if randi() % 2 + 1 == 1:
		randomPositionOffsetY *= -1
	
	var targetPosition: Vector2 = global_position + Vector2(randomPositionOffsetX, randomPositionOffsetY)
	var distanceToTargetPosition: float = global_position.distance_squared_to(targetPosition)
	var tween: Tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "global_position", targetPosition, distanceToTargetPosition / explodeVelocity)
	tween.connect("finished", allowMovingTowardsPlayer)

func allowMovingTowardsPlayer() -> void:
	canMoveTowardsPlayer = true
	
	if is_instance_valid(get_tree().get_nodes_in_group("Player")[0]):
		player = get_tree().get_nodes_in_group("Player")[0]

func moveTowardsPlayer(delta: float) -> void:
	if canMoveTowardsPlayer:
		global_position = global_position.move_toward(player.global_position, velocity * delta)
