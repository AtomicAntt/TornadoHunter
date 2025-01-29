class_name BossHealth
extends TextureProgressBar

@onready var progress_under: TextureProgressBar = $ProgressUnder
@export var duration: float = 0.4

func change_health(max_health: float, health: float) -> void:
	max_value = max_health
	$ProgressUnder.max_value = max_health
	
	#var new_value: float = health
	#value = new_value
	
	value = health
	
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(progress_under, "value", health, duration).set_trans(Tween.TRANS_CUBIC)
	
	#tween.tween_property(progress_under, "value", new_value, duration).set_trans(Tween.TRANS_CUBIC)
