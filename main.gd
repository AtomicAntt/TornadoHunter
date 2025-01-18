class_name Main
extends Control

@onready var world = $World
var level_instance: Node2D

var shop: Resource = preload("res://GameObjects/Shop/Shop.tscn")

var current_scene: String
var current_level: int = 1

func _ready() -> void:
	load_level("Level2")

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
	
	unload_level()
	var level_path: String = "res://Levels/%s.tscn" % level_name
	var level_resource: Resource = load(level_path)
	
	if level_resource:
		level_instance = level_resource.instantiate()
		world.add_child(level_instance)
	
	current_scene = level_name
	
	tween = create_tween()
	tween.tween_property(
		$World/CanvasLayer/SceneTransition.material,
		"shader_parameter/progress",
		0.0,
		1
	).from(1.0).set_trans(Tween.TRANS_CUBIC)
	
	await tween.finished
	
	if level_name != "Shop":
		$BossMusic.play()
		$ShopMusic.stop()
	else:
		$BossMusic.stop()
		$ShopMusic.play()

func level_success() -> void:
	await get_tree().create_timer(1.0).timeout
	
	var gate: Gate = get_tree().get_nodes_in_group("Gate")[0]
	gate.cutscene()

func restart() -> void:
	load_level(current_scene)
	#$BossMusic.play()

func level_fail() -> void:
	$BossMusic.stop()
	await get_tree().create_timer(1.5).timeout
	
	restart()

func load_next_level() -> void:
	current_level += 1
	load_level("Level" + str(current_level))
