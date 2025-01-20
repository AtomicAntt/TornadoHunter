class_name ClockBoss
extends Boss

func _physics_process(delta: float) -> void:
	match state:
		States.IDLE:
			pass

func set_idle() -> void:
	if state != States.DISABLED:
		state = States.IDLE
