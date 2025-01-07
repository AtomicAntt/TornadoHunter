class_name Shield
extends Area2D

var max_recharge: float = 5.0
var recharge: float = 5.0

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
