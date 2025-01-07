extends Boss

enum States {STUNNED, ACCELERATING, CHARGING, IDLE, DEAD}
var state: States = States.STUNNED

var spin_speed: float = 0.0
@export var spin_acceleration: float = 200.0
@export var speed_to_charge: float = 1000.0

var last_player_direction: Vector2 = Vector2.ZERO

func _physics_process(delta: float) -> void:
	
	match state:
		States.IDLE:
			pass
		States.ACCELERATING:
			spin_speed += spin_acceleration * delta
			rotation_degrees += spin_speed * delta
			
			while rotation_degrees > 360:
				rotation_degrees -= 360
			
			if spin_speed <= speed_to_charge * 0.75:
				var player: Player = get_tree().get_nodes_in_group("Player")[0]
				if is_instance_valid(player):
					last_player_direction = global_position.direction_to(player.global_position) # Get this to figure out where to charge at, it decides when its 75% done charging
					if last_player_direction.x > 0:
						$Node/Line2D.set_point_position(0, position)
						$Node/Line2D.set_point_position(1, player.position)
					else:
						$Node/Line2D.set_point_position(1, position)
						$Node/Line2D.set_point_position(0, player.position)
			
			if spin_speed >= speed_to_charge:
				$Node/Line2D.visible = false
				state = States.CHARGING
				
		States.CHARGING:
			spin_speed -= spin_acceleration * delta
			rotation_degrees -= spin_speed * delta
			
			while rotation_degrees < -360:
				rotation_degrees += 360
			
			global_position += last_player_direction * spin_speed * delta
		States.STUNNED:
			pass

func _on_intro_timeout() -> void:
	accelerate()

func stun() -> void:
	state = States.STUNNED
	$StunAnimation.visible = true
	$StunAnimation.play("Stunned")

func accelerate() -> void:
	state = States.ACCELERATING
	$StunAnimation.visible = false
	$StunAnimation.stop()
	$Node/Line2D.visible = true

func _on_stun_timer_timeout() -> void:
	print("READY TO ROLL")
	accelerate()

func _on_charge_hitbox_body_entered(body: Node2D) -> void:
	if state == States.CHARGING:
		stun()
		spin_speed = 0
		$StunTimer.start()
		
		# then i stand back up
		var tween: Tween = get_tree().create_tween()
		tween.tween_property(self, "rotation_degrees", 0, 0.5)
