class_name TutorialKey
extends AnimatedSprite2D

@export var key: String = "Up"

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed(key+"key"):
		play(key+"pressed")
	else:
		play(key)
