extends Node2D

var seconds_held: float = 0.0
var seconds_to_hold: float = 0.5

var hold_completed: bool = false
var key_pressed: bool = false

var completed_color: Color = Color("fbf234")

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("fire") and not hold_completed:
		seconds_held += delta
		$MouseInstructions/Mouse.play("Hold")
		if seconds_held >= seconds_to_hold:
			hold_completed = true
			$Complete.play()
			$MouseInstructions/MouseLabel.modulate = completed_color
			check_complete()
	elif not hold_completed and not Input.is_action_pressed("fire"):
		seconds_held -= delta

	if not Input.is_action_pressed("fire"):
		$MouseInstructions/Mouse.play("default")
	
	if (Input.is_action_just_pressed("up") or Input.is_action_just_pressed("left") or Input.is_action_just_pressed("down") or Input.is_action_just_pressed("right")) and (not key_pressed):
		key_pressed = true
		$Complete.play()
		$Controls/KeyboardLabel.modulate = completed_color
		check_complete()
		
	$TutorialProgressBar.value = (seconds_held / seconds_to_hold) * 100
	seconds_held = clampf(seconds_held, 0.0, 1.0)

func check_complete() -> void:
	if hold_completed and key_pressed:
		var gate: Gate = get_tree().get_nodes_in_group("Gate")[0]
		gate.cutscene()
