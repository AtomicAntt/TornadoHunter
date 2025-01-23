class_name Minion
extends Area2D

@export var minion_max_health = 100
@export var minion_health = 100

@onready var progress_under: TextureProgressBar = $HealthBar/DamageBar
@export var duration: float = 0.3

enum States {DISABLED, IDLE, CHARGING, STUNNED}
var state: States = States.IDLE

func change_health(max_health: float, health: float) -> void:
	var new_value: float = (health/max_health) * 100
	$HealthBar.value = new_value
	
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(progress_under, "value", new_value, duration)

func hurt(damage: float) -> void:
	minion_health -= damage
	change_health(minion_max_health, minion_health)
	
	$HurtAnimation.play("Hurt")
	$Hurt.play()
	$Hurt.set_pitch_scale(randf_range(0.5, 1.5))
	
	if minion_health <= 0:
		death()
	
func death() -> void:
	if state != States.DISABLED:
		state = States.DISABLED
		$AnimatedSprite2D.visible = false
		$DeathSprite.visible = true
		
		$DeathAnimation.play("Death")
		$Death.play()
