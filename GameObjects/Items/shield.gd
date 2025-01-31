class_name Shield
extends Area2D

enum Shields {NONE, TIME}
@export var shield: Shields = Shields.NONE

var max_recharge: float = 25.0
var recharge: float = 25.0

@export var sell_value: int

func _physics_process(delta: float) -> void:
	if recharge < max_recharge:
		recharge += delta
		$AnimatedSprite2D.modulate = Color("#ff312a")
		modulate.a = recharge / max_recharge
	else:
		$AnimatedSprite2D.modulate = Color("#ffffff")

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("EnemyAttack") && recharge >= max_recharge:
		var enemyAttack: EnemyProjectile = area
		enemyAttack.queue_free()
		use_shield()

func use_shield() -> void:
	recharge = 0.0
	
	var camera_shake: CameraShaker = get_tree().get_nodes_in_group("Camera")[0]
	if is_instance_valid(camera_shake):
		camera_shake.apply_weak_shake()
	
	if shield == Shields.TIME:
		var main: Main = get_tree().get_nodes_in_group("Main")[0]
		main.freeze_time(2.0)
		$TimeFreeze.play()
	else:
		$Block.play()
