class_name ItemDrop
extends Pickup

@export var item: PackedScene

func _ready() -> void:
	refresh_sprite()
	$Appear.play()

func _physics_process(delta: float) -> void:
	moveTowardsPlayer(delta) # Remember, this only happens if it is allowed to (which is if exploded or else explicitly allowed from Pickup class)

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("PlayerHitbox") and canMoveTowardsPlayer:
		var player: Player = get_tree().get_nodes_in_group("Player")[0]
		if is_instance_valid(player):
			var item_instance: Area2D = item.instantiate()
			player.add_item_orbit(item_instance)
			queue_free()

func set_item(item_set: PackedScene) -> void:
	item = item_set

func refresh_sprite() -> void:
	for child in get_children():
		if child is AnimatedSprite2D:
			child.queue_free()
	
	var item_instance: Area2D = item.instantiate()
	var sprite: AnimatedSprite2D = item_instance.get_node("AnimatedSprite2D")
	var sprite_instance: AnimatedSprite2D = sprite.duplicate()
	add_child(sprite_instance)
