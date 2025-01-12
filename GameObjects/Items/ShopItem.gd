extends Area2D

@export var item_sold: PackedScene
@export var item_group: String

var player_in_range: bool = false

var item_drop: Resource = preload("res://GameObjects/Items/ItemDrop.tscn")

var current_cost: int = 10

# I will be manually putting the sprite with the correct item to be compatible with shader

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("PlayerHitbox"):
		$Instructions.visible = true
		player_in_range = true

func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("PlayerHitbox"):
		$Instructions.visible = false
		player_in_range = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and player_in_range and Global.gold >= current_cost:
		var main: Main = get_tree().get_nodes_in_group("Main")[0]
		var item_instance: ItemDrop = item_drop.instantiate()
		
		item_instance.set_item(item_sold)
		item_instance.refresh_sprite()
		item_instance.global_position = global_position
		
		main.level_instance.call_deferred("add_child", item_instance)
		Global.add_gold(-current_cost)

		item_instance.explodeMinDistance = 50
		item_instance.explodeMaxDistance = 70
		item_instance.explodeVelocity = 30000
		item_instance.velocity = 360
		item_instance.explode_outwards()
