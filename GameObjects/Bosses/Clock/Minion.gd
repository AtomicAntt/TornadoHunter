class_name Minion
extends Area2D

@export var minion_max_health: float = 100
@export var minion_health: float = 100

@onready var progress_under: TextureProgressBar = $HealthBar/DamageBar
var duration: float = 0.3

@export var speed: float = 100
@export var charging_speed: float = 1000.0

var current_pos: Marker2D

var movement_tween: Tween

var move_cooldown: float = 1.5 # Time it takes before it takes an action and gets out of idle state
var move_time: float = 0.0

var charging_cooldown: float = 1.0 # Time it takes to warn the player before charging
var charge_time: float = 0.0

var stun_cooldown: float = 5.0 # Time it takes to get unstunned
var stun_time: float = 0.0

var last_player_direction: Vector2

enum States {DISABLED, IDLE, CHARGING, STUNNED, MOVING, WARNING}
var state: States = States.IDLE

func _ready() -> void:
	$TeleportAnimation.play("Teleport")

func _physics_process(delta: float) -> void:
	match state:
		States.IDLE:
			move_time += delta
			
			if move_time >= move_cooldown:
				move_randomly() # Also resets move time
		States.DISABLED: # Dead
			if is_instance_valid(movement_tween):
				if movement_tween.is_running():
					movement_tween.stop()
		States.CHARGING: # Goes towards the player until it hits the wall or the player. Afterwards, it gets stunned.
			global_position += last_player_direction * charging_speed * delta
		States.STUNNED: # Do nothing for a time, then go back to IDLE.
			stun_time += delta
			
			if stun_time >= stun_cooldown:
				set_idle()
		States.MOVING: # When moving is set (likely from IDLE), a tween is ran. When the tween is no longer running, the minion has reached its destination and will send a warning to charge at the player.
			if is_instance_valid(movement_tween):
				if not movement_tween.is_running():
					start_warning()
		States.WARNING: # After moving, the minion will warn the player where it is going to go.
			charge_time += delta
			
			if charge_time >= charging_cooldown:
				charge_time = 0.0
				start_charging()
			

func set_idle() -> void:
	state = States.IDLE
	$StunAnimation.visible = false

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

func move_randomly() -> void:
	state = States.MOVING
	move_time = 0.0
	
	var valid_positions: Array[Marker2D] = []
	for random_pos: Marker2D in get_tree().get_nodes_in_group("MinionPosition"):
		if random_pos != current_pos:
			valid_positions.append(random_pos)
	
	var selected_marker: Marker2D = valid_positions.pick_random()
	current_pos = selected_marker
	
	movement_tween = get_tree().create_tween()
	movement_tween.tween_property(self, "global_position", selected_marker.global_position, global_position.distance_to(selected_marker.global_position) / speed).set_trans(Tween.TRANS_CUBIC)

func start_warning() -> void:
	state = States.WARNING
	
	var player_direction: Vector2 = global_position.direction_to(get_tree().get_nodes_in_group("Player")[0].global_position)
	last_player_direction = player_direction
	
	$Node/Line2D.visible = true
	
	if player_direction.x > 0:
		$Node/Line2D.set_point_position(0, position)
		$Node/Line2D.set_point_position(1, position + (player_direction * 1000))
	else:
		$Node/Line2D.set_point_position(1, position)
		$Node/Line2D.set_point_position(0, position + (player_direction * 1000))
	
	$Node/Line2D/AnimationPlayer.play("Warning")
	$Warning.play()

func start_charging() -> void:
	state = States.CHARGING
	
	$Node/Line2D.visible = false
	$Node/Line2D/AnimationPlayer.stop()


func stun() -> void:
	if state != States.DISABLED:
		state = States.STUNNED
		$StunAnimation.visible = true
		$StunAnimation.play("Stunned")

func impact(sound: bool) -> void:
	stun()
	if sound:
		$Impact.play()
		
	# then i stand back up
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "rotation_degrees", 0, 0.5)
	
	var camera_shaker: CameraShaker = get_tree().get_nodes_in_group("Camera")[0]
	if is_instance_valid(camera_shaker):
		camera_shaker.apply_medium_shake()

func _on_charge_hitbox_body_entered(body: Node2D) -> void:
	if state == States.CHARGING and state != States.DISABLED:
		impact(true)

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("PlayerHitbox") and state == States.CHARGING and state != States.DISABLED:
		var player: Player = get_tree().get_nodes_in_group("Player")[0]
		if is_instance_valid(player):
			player.hurt(2)
			impact(false)
