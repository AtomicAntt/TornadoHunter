extends Area2D

@export_multiline var description: String
var in_range: bool = false

#func _ready() -> void:
	#Global.update_gold.connect(refresh_status)

func _physics_process(delta: float) -> void:
	refresh_status()

func refresh_status() -> void:
	var weapon_count: int = 0
	
	for weapon in get_tree().get_nodes_in_group("weapon"):
		if not weapon.is_in_group("BossItem"):
			weapon_count += 1
	
	if weapon_count > 0:
		$WeaponRefundLabel.modulate = Color("#ffffff")
	else:
		$WeaponRefundLabel.modulate = Color("#ff3b2cb1")

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("PlayerHitbox"):
		in_range = true
		display_description()
		var weapon_count: int = 0
	
		for weapon in get_tree().get_nodes_in_group("weapon"):
				if not weapon.is_in_group("BossItem"):
					weapon_count += 1
		if weapon_count > 0:
			$Instructions.visible = true
		
func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("PlayerHitbox"):
		in_range = false
		$Instructions.visible = false
		hide_description()

func _input(event: InputEvent) -> void:
	var weapon_count: int = 0
	
	for weapon in get_tree().get_nodes_in_group("weapon"):
			if not weapon.is_in_group("BossItem"):
				weapon_count += 1
	
	if event.is_action_pressed("interact") and in_range and get_tree().get_node_count_in_group("ItemDrop") <= 0 and weapon_count > 0:
		for weapon: PlayerWeapon in get_tree().get_nodes_in_group("weapon"):
			if not weapon.is_in_group("BossItem"):
				weapon.queue_free()
				Global.add_gold(weapon.sell_value)
				$GetCoin.play()
				$Instructions.visible = false
		$WeaponRefundLabel.modulate = Color("#ff3b2cb1")

		description = "Refund weapons?\nCount: [color=red]0[/color]" # Purpose: After selling items, the shopkeeper should update the description to the # items owned now (which is 0)
		
		var shopNPC: ShopNPC = get_tree().get_first_node_in_group("ShopNPC")
		if is_instance_valid(shopNPC):
			shopNPC.show_text(description)
	
	elif event.is_action_pressed("interact") and in_range:
		$InvalidPurchase.play()
		

func display_description() -> void:
	var shopNPC: ShopNPC = get_tree().get_first_node_in_group("ShopNPC")
	var weapon_count: int = 0
	var weapons_value: int = 0
	
	for weapon in get_tree().get_nodes_in_group("weapon"):
			if not weapon.is_in_group("BossItem"):
				weapon_count += 1
				weapons_value += weapon.sell_value
	
	if weapon_count > 0:
		description = "Refund weapons?\nCount: [color=blue]" + str(weapon_count) + "[/color] (" + str(weapons_value) + " gold)"
	else:
		description = "Refund weapons?\nCount: [color=red]" + str(weapon_count) + "[/color]"
	
	if is_instance_valid(shopNPC):
		shopNPC.show_text(description)

func hide_description() -> void:
	var shopNPC: ShopNPC = get_tree().get_first_node_in_group("ShopNPC")
	if is_instance_valid(shopNPC):
		shopNPC.hide_text()
