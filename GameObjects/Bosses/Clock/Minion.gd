class_name Minion
extends Area2D

@export var minion_max_health: float = 100
@export var minion_health: float = 100

@onready var progress_under: TextureProgressBar = $HealthBar/DamageBar
var duration: float = 0.3

@export var speed: float = 100

var current_pos: Marker2D

var movement_tween: Tween

var move_cooldown: float = 3.0 # Time it takes before it takes an action and gets out of idle state
var move_time: float = 0.0

enum States {DISABLED, IDLE, CHARGING, STUNNED, MOVING, WARNING}
var state: States = States.IDLE

func _physics_process(delta: float) -> void:
	match state:
		States.IDLE:
			move_time += delta
			
			if move_time >= move_cooldown:
				move_randomly() # Also resets move time
		States.DISABLED: # Dead
			pass
		States.CHARGING:
			pass
		States.STUNNED:
			pass
		States.MOVING: # When moving is set, a tween is ran. When the tween is no longer running, the minion has reached its destination and will send a warning to charge at the player.
			if is_instance_valid(movement_tween):
				if not movement_tween.is_running():
					set_idle()

func set_idle() -> void:
	state = States.IDLE

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
	move_time = 0.0
	
	var valid_positions: Array[Marker2D] = []
	for random_pos: Marker2D in get_tree().get_nodes_in_group("MinionPosition"):
		if random_pos != current_pos:
			valid_positions.append(random_pos)
	
	var selected_marker: Marker2D = valid_positions.pick_random()
	current_pos = selected_marker
	
	movement_tween = get_tree().create_tween()
	movement_tween.tween_property(self, "global_position", selected_marker.global_position, global_position.distance_to(selected_marker.global_position) / speed).set_trans(Tween.TRANS_CUBIC)
