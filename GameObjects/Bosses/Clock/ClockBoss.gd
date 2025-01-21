class_name ClockBoss
extends Boss

var position_index: int = 0 # Basically this loops through the positions of 0, 1, and 2 using the modulo operator
var new_marker: Marker2D

var move_cooldown: float = 2.0 # Time it takes before it takes an action and gets out of idle state
var move_time: float = 0.0

func _physics_process(delta: float) -> void:
	match state:
		States.IDLE:
			if $Intro.is_stopped():
				move_time += delta
			
			if move_time >= move_cooldown:
				move_time = 0.0
				set_moving()
		States.MOVING:
			pass

func set_idle() -> void:
	if state != States.DISABLED:
		state = States.IDLE

func set_moving() -> void:
	state = States.MOVING
	$TeleportAnimation.play("Teleport")

func set_new_marker() -> void:
	position_index += 1
	
	# position_index % 3 basically, which loops from 0, 1, and 2
	new_marker = get_tree().get_nodes_in_group("BossPosition")[position_index % get_tree().get_node_count_in_group("BossPosition")]

# ====================================== METHODS CALLED BY ANIMATIONPLAYER ================================

# This will be called by the DeathAnimation
func visit_new_marker() -> void:
	set_new_marker()
	global_position = new_marker.global_position

# This will be called by the DeathAnimation
func summon_clocks() -> void:
	pass

# ====================================== SIGNAL METHODS =================================

func _on_intro_timeout() -> void:
	set_moving()
