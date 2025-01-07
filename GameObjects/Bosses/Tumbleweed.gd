extends Boss

enum States {STUNNED, ACCELERATING, CHARGING, IDLE, DEAD}
var state: States = States.STUNNED

var spin_speed: float = 0.0
@export var spin_acceleration: float = 200.0
@export var speed_to_charge: float = 1000.0

var last_player_position: Vector2 = Vector2.ZERO

func _physics_process(delta: float) -> void:
	match state:
		States.IDLE:
			pass
		States.ACCELERATING:
			spin_speed += spin_acceleration * delta
			rotation_degrees += spin_speed * delta
			
			while rotation_degrees > 360:
				rotation_degrees -= 360
			
			if spin_speed >= speed_to_charge:
				state = States.CHARGING
				var player: Player = get_tree().get_nodes_in_group("Player")[0]
				if is_instance_valid(player):
					last_player_position = player.global_position
		States.CHARGING:
			spin_speed -= spin_acceleration * delta
			rotation_degrees -= spin_speed * delta
			
			global_position += global_position.direction_to(last_player_position) * spin_speed * delta
		States.STUNNED:
			pass

func _on_intro_timeout() -> void:
	accelerate()

func _on_body_entered(body: Node2D) -> void:
	if state == States.CHARGING:
		stun()
		spin_speed = 0
		$StunTimer.start()

func stun() -> void:
	state = States.STUNNED
	$StunAnimation.visible = true
	$StunAnimation.play("Stunned")

func accelerate() -> void:
	state = States.ACCELERATING
	$StunAnimation.visible = false
	$StunAnimation.stop()

func _on_stun_timer_timeout() -> void:
	print("READY TO ROLL")
	accelerate()
