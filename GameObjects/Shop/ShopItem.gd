extends Area2D

@export var item_sold: PackedScene

# So you can calculate the cost of the item by how many items in this group currently exists.
@export var item_group: String

var player_in_range: bool = false

var item_drop: Resource = preload("res://GameObjects/Items/ItemDrop.tscn")

var current_cost: int = 10

@export var single_purchase: bool = false # Ex.: Shield is single purchase since having many is too good.

# I will be manually putting the sprite with the correct item to be compatible with shader

func _ready() -> void:
	#current_cost = 5 * pow(2, get_tree().get_node_count_in_group(item_group))
	#refresh_status(Global.gold)
	Global.update_gold.connect(refresh_status)

func _physics_process(delta: float) -> void:
	if get_tree().get_node_count_in_group("ItemDrop") <= 0:
		current_cost = 20 * (get_tree().get_node_count_in_group(item_group))
	refresh_status(Global.gold)
	

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("PlayerHitbox"):
		if Global.gold >= current_cost:
			$Instructions.visible = true
		player_in_range = true

func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("PlayerHitbox"):
		$Instructions.visible = false
		player_in_range = false

var purchasing: bool = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and player_in_range and Global.gold >= current_cost and not purchasing and get_tree().get_node_count_in_group("ItemDrop") <= 0:
		purchasing = true
		Global.add_gold(-current_cost)
		
		# Why do I do this? Before the item is spawned for the player to grab, we should assume they will have that weapon in the future when they pick it up, so the price should be adjusted right away.
		#current_cost = 5 * pow(2, get_tree().get_node_count_in_group(item_group) + 1)
		current_cost = 20 * (get_tree().get_node_count_in_group(item_group) + 1)
		
		refresh_status(Global.gold)
		
		var main: Main = get_tree().get_nodes_in_group("Main")[0]
		var item_instance: ItemDrop = item_drop.instantiate()
		
		item_instance.set_item(item_sold)
		item_instance.refresh_sprite()
		item_instance.global_position = global_position
		
		main.level_instance.call_deferred("add_child", item_instance)

		item_instance.explodeMinDistance = 50
		item_instance.explodeMaxDistance = 70
		item_instance.explodeVelocity = 30000
		item_instance.velocity = 360
		item_instance.explode_outwards()
		
		purchasing = false
	elif event.is_action_pressed("interact") and player_in_range:
		$InvalidPurchase.play()

# Call on ready or whenever gold is updated. Takes care of edge cases like if the player is in range, purchased an item, and can no longer purchase the item and thus should not be able to see instructions.
func refresh_status(current_gold: int) -> void:
	#current_cost = 10 * pow(2, get_tree().get_node_count_in_group("weapon"))
	$CostContainer/Label.text = str(current_cost)
	
	if current_gold < current_cost:
		$CostContainer.modulate = Color("#ff3b2cb1")
		$Instructions.visible = false
	else:
		$CostContainer.modulate = Color("#ffffff")
		if player_in_range:
			$Instructions.visible = true
		else:
			$Instructions.visible = false
			
