class_name Gate
extends StaticBody2D

@onready var cutscene_camera = $Camera
var current_camera: CameraShaker

var open: bool = false

@export var is_shop: bool = false

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
	await get_tree().create_timer(1.0).timeout
	$Sprite2D.visible = false
	$CollisionShape2D.set_deferred("disabled", true)
	await get_tree().create_timer(1.0).timeout
	
	tween = create_tween()
	tween.tween_property(cutscene_camera, "global_position", current_camera.global_position, 1)
	
	await tween.finished
	
	current_camera.enabled = true
	cutscene_camera.enabled = false
	
	open = true

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("PlayerHitbox") and open:
		open = false
		var main: Main = get_tree().get_nodes_in_group("Main")[0]
		if not is_shop:
			main.load_level("Shop")
