extends Area2D

@export var item_sold: PackedScene

# So you can calculate the cost of the item by how many items in this group currently exists.
#@export var item_group: String
@export_multiline var item_description: String

@export var item_name: String # Purpose: Global will track if the item has been visited. If not yet, this will display on _ready().

@export var required_special_weapons: int = 0 # Purpose: Depending on how many special weapons the player has, see if it exists or not, else it is queue_free'd

var player_in_range: bool = false

var item_drop: Resource = preload("res://GameObjects/Items/ItemDrop.tscn")

@export var current_cost: int = 10

# Im just gonna make a shield expensive
#@export var single_purchase: bool = false # Ex.: Shield is single purchase since having many is too good.
#var available: bool = true # Once a single purchase is made, you may remove the 

# I will be manually putting the sprite with the correct item to be compatible with shader

func _ready() -> void:
	
	#current_cost = 5 * pow(2, get_tree().get_node_count_in_group(item_group))
	refresh_status(Global.gold)
	Global.update_gold.connect(refresh_status)
	if item_name in Global.items_viewed:
		$NewLabel.visible = false
	
	if required_special_weapons > Global.special_weapon_count:
		queue_free()

#func _physics_process(delta: float) -> void:
	#if get_tree().get_node_count_in_group("ItemDrop") <= 0:
		#current_cost = 20 * (get_tree().get_node_count_in_group(item_group))
	#refresh_status(Global.gold)
	

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("PlayerHitbox"):
		if Global.gold >= current_cost:
			$Instructions.visible = true
		player_in_range = true
		display_description()
		if item_name not in Global.items_viewed:
			Global.items_viewed.append(item_name)
		$NewLabel.visible = false

func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("PlayerHitbox"):
		$Instructions.visible = false
		player_in_range = false
		hide_description()

var purchasing: bool = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and player_in_range and Global.gold >= current_cost and not purchasing:
		purchasing = true
		Global.add_gold(-current_cost)
		
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
		$Appear.play()
		
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

func display_description() -> void:
	var shopNPC: ShopNPC = get_tree().get_first_node_in_group("ShopNPC")
	if is_instance_valid(shopNPC):
		shopNPC.show_text(item_description)

func hide_description() -> void:
	var shopNPC: ShopNPC = get_tree().get_first_node_in_group("ShopNPC")
	if is_instance_valid(shopNPC):
		shopNPC.hide_text()
