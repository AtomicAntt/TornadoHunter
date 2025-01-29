extends Node2D

var seconds_held: float = 0.0
var seconds_to_hold: float = 1.0
var hold_completed: bool = false

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("fire") and not hold_completed:
		seconds_held += delta
		$Mouse.play("Hold")
		if seconds_held >= seconds_to_hold:
			hold_completed = true
	elif not hold_completed and not Input.is_action_pressed("fire"):
		seconds_held -= delta
		$Mouse.play("default")
	
	$TutorialProgressBar.value = (seconds_held / seconds_to_hold) * 100
	seconds_held = clampf(seconds_held, 0.0, 1.0)
