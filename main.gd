class_name Main
extends Control

@onready var world = $World
var level_instance: Node2D

var shop: Resource = preload("res://GameObjects/Shop/Shop.tscn")
var item_drop: Resource = preload("res://GameObjects/Items/ItemDrop.tscn")
var boss_drop: PackedScene = preload("res://GameObjects/Items/TumbleweedDagger.tscn")
var tornado_drop: PackedScene = preload("res://GameObjects/Items/TornadoDagger.tscn")
var clock_drop: PackedScene = preload("res://GameObjects/Items/TimeShield.tscn")

var cursor: Resource = preload("res://GameAssets/UI/Mouse/Cursor-4.png")

var current_scene: String
var current_level: int = 1

#func _ready() -> void:
	#Input.set_custom_mouse_cursor(cursor) # Set to null for the default one

func unload_level() -> void:
	if is_instance_valid(level_instance):
		level_instance.queue_free()
	level_instance = null

func load_level(level_name: String) -> void:
	$World/CanvasLayer/SceneTransition.material["shader_parameter/progress"] = 0.0
	var tween: Tween = create_tween()
	tween.tween_property(
		$World/CanvasLayer/SceneTransition.material,
		"shader_parameter/progress",
		1.0,
		1
	).from(0.0).set_trans(Tween.TRANS_CUBIC)
	
	await tween.finished
	
	#Let player see the game ui stuff and hide any main menu stuff
	$World/CanvasLayer/VBoxContainer.visible = true
	$MainMenu.visible = false
	unload_level()
	var level_path: String = "res://Levels/%s.tscn" % level_name
	var level_resource: Resource = load(level_path)
	
	if level_resource:
		level_instance = level_resource.instantiate()
		world.add_child(level_instance)
	
	current_scene = level_name
	
	if level_name != "Shop" and level_name != "Tutorial":
		$World/CanvasLayer/BossHealthBar.visible = true
		$World/CanvasLayer/StageLabel.visible = true
		$World/CanvasLayer/StageLabel.text = "Stage " + str(current_level)
	else:
		$World/CanvasLayer/StageLabel.visible = false
		$World/CanvasLayer/BossHealthBar.visible = false
	
	tween = create_tween()
	tween.tween_property(
		$World/CanvasLayer/SceneTransition.material,
		"shader_parameter/progress",
		0.0,
		1
	).from(1.0).set_trans(Tween.TRANS_CUBIC)
	
	await tween.finished

	if level_name == "Shop":
		$BossMusic.stop()
		$ShopMusic.play()
	elif level_name == "Tutorial":
		$TutorialMusic.play()
	else:
		$BossMusic.play()
		$ShopMusic.stop()
		$TutorialMusic.stop()
	
	

func level_success() -> void:
	# Logic is that since players can go back levels, the special weapon amount only increments when the level is newly defeated.
	
	if Global.special_weapon_count < current_level and current_level <= 3:
		var item_instance: ItemDrop = item_drop.instantiate()
		
		match current_level:
			1:
				item_instance.set_item(boss_drop)
			2:
				item_instance.set_item(tornado_drop)
			3:
				item_instance.set_item(clock_drop)
		
		item_instance.refresh_sprite()
		item_instance.global_position = get_tree().get_nodes_in_group("CenterMarker")[0].global_position
			
		call_deferred("add_child", item_instance)

		item_instance.explodeMinDistance = 0
		item_instance.explodeMaxDistance = 0
		item_instance.explodeVelocity = 0
		item_instance.velocity = 0
		item_instance.explode_outwards()
		item_instance.god_ray()
	
		Global.special_weapon_count += 1
	#if Global.special_weapon_count < current_level:
	
	await get_tree().create_timer(1.0).timeout
	
	var gate: Gate = get_tree().get_nodes_in_group("Gate")[0]
	gate.cutscene()

func restart() -> void:
	#load_level(current_scene)
	#$BossMusic.play()
	
	load_level("Shop")
	current_level = 0
	Global.health = 6

func level_fail() -> void:
	$BossMusic.stop()
	await get_tree().create_timer(1.5).timeout
	
	restart()

func load_next_level() -> void:
	current_level += 1
	load_level("Level" + str(current_level))

var time_frozen: float = 0.0
var is_frozen: bool = false

func _physics_process(delta: float) -> void:
	$World/CanvasLayer/TimeCounterLabel.text = str(snapped(time_frozen, 0.1))
	if is_frozen:
		time_frozen -= delta
	
		if time_frozen <= 0:
			time_frozen = 0.0
			resume_time()

func freeze_time(seconds: float) -> void:
	time_frozen += seconds
	if not is_frozen:
		is_frozen = true
		var tween: Tween = create_tween()
		tween.tween_method(set_time, Global.time_scale, 0.0, 0.2).set_trans(Tween.TRANS_CUBIC)
		tween.set_parallel()
		tween.tween_property($World/CanvasLayer/Grayscale.material, "shader_parameter/grayness", 1.0, 0.2).from(0.0).set_trans(Tween.TRANS_CUBIC)
		tween.set_parallel()
		tween.tween_property($World/CanvasLayer/TimeCounterLabel, "modulate:a", 1.0, 0.2).set_trans(Tween.TRANS_CUBIC)
	

func resume_time() -> void:
	if is_frozen:
		is_frozen = false
		var tween: Tween = create_tween()
		tween.tween_method(set_time, Global.time_scale, 1.0, 0.2).set_trans(Tween.TRANS_CUBIC)
		tween.set_parallel()
		tween.tween_property($World/CanvasLayer/Grayscale.material, "shader_parameter/grayness", 0.0, 0.2).from(1.0).set_trans(Tween.TRANS_CUBIC)
		tween.set_parallel()
		tween.tween_property($World/CanvasLayer/TimeCounterLabel, "modulate:a", 0.0, 0.2).set_trans(Tween.TRANS_CUBIC)
	
func set_time(value: float) -> void:
	Global.time_scale = value

func _on_start_button_pressed() -> void:
	$MainMenu/MenuButtons/StartButton.disabled = true # Remember to re-enable it if the player ever comes back to the main menu!
	$ButtonPressed.play()
	$MenuMusic.stop()
	Input.set_custom_mouse_cursor(cursor)
	load_level("Tutorial")
	# I will set it during load_level() function
	#$MainMenu.visible = false 

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_button_mouse_entered() -> void:
	$ButtonHover.play()
