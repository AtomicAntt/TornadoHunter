class_name BossHealth
extends TextureProgressBar

@onready var progress_under: TextureProgressBar = $ProgressUnder
@export var duration: float = 0.3

func change_health(max_health: float, health: float) -> void:
	var new_value: float = (health/max_health) * 100
	value = new_value
	
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(progress_under, "value", new_value, duration)
