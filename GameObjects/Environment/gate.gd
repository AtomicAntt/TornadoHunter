class_name Gate
extends StaticBody2D

@onready var cutscene_camera = $Camera
var current_camera: CameraShaker

var open: bool = false

@export var is_shop: bool = false
@export var is_tutorial: bool = false

func _ready() -> void:
	if is_shop:
		$Sprite2D.visible = false
		$CollisionShape2D.set_deferred("disabled", true)

func cutscene() -> void:
	for camera: CameraShaker in get_tree().get_nodes_in_group("Camera"):
		if camera.enabled:
			current_camera = camera
	
	cutscene_camera.global_position = current_camera.global_position
	
	current_camera.enabled = false
	cutscene_camera.enabled = true
	
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(cutscene_camera, "global_position", self.global_position, 1)
	
	await tween.finished
	await get_tree().create_timer(0.5).timeout
	
	$Sprite2D.visible = false
	$CollisionShape2D.set_deferred("disabled", true)
	$Camera.apply_medium_shake()
	$Open.play()
	
	await get_tree().create_timer(0.5).timeout
	
	tween = create_tween()
	tween.tween_property(cutscene_camera, "global_position", current_camera.global_position, 1)
	
	await tween.finished
	
	current_camera.enabled = true
	cutscene_camera.enabled = false
	
	open = true
	
	# If the player is standing next to the gate already
	
	for area in $Area2D.get_overlapping_areas():
		if area.is_in_group("PlayerHitbox") and get_tree().get_node_count_in_group("ItemDrop") <= 0:
			open = false
			var main: Main = get_tree().get_nodes_in_group("Main")[0]
			if not is_shop and not is_tutorial and main.current_level < 7:
				main.load_level("Shop")
			elif not is_shop and not is_tutorial and main.current_level >= 7:
				main.load_level("Win")
			elif is_tutorial:
				main.load_level("Level1")

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("PlayerHitbox") and open and get_tree().get_node_count_in_group("ItemDrop") <= 0 and not is_tutorial:
		open = false
		print(get_tree().get_node_count_in_group("ItemDrop"))
		var main: Main = get_tree().get_nodes_in_group("Main")[0]
		if not is_shop and main.current_level < 7:
			main.load_level("Shop")
		elif not is_shop and main.current_level >= 7:
			main.load_level("Win")
	if area.is_in_group("PlayerHitbox") and is_shop and get_tree().get_node_count_in_group("ItemDrop") <= 0: # Item drop count must be 0 so it can save your purchases easier
		is_shop = false # This is just so that you can't activate it again to cause weird stuff.
		
		#Global.weapon_count = get_tree().get_node_count_in_group("Dagger")
		#Global.sword_count = get_tree().get_node_count_in_group("Sword")
		#Global.fire_blade_count = get_tree().get_node_count_in_group("FireBlade")
		var player: Player = get_tree().get_first_node_in_group("Player")
		player.update_weapon_stack()
		
		Global.shield_count = get_tree().get_node_count_in_group("RegularShield")
		
		var main: Main = get_tree().get_nodes_in_group("Main")[0]
		main.load_next_level()
	if area.is_in_group("PlayerHitbox") and is_tutorial and open:
		open = false
		var main: Main = get_tree().get_nodes_in_group("Main")[0]
		main.load_level("Level1")
