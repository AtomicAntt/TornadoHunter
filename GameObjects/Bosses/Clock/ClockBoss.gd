class_name ClockBoss
extends Boss

var position_index: int = 0 # Basically this loops through the positions of 0, 1, and 2 using the modulo operator
var new_marker: Marker2D

var move_cooldown: float = 2.0 # Time it takes before it takes an action and gets out of idle state
var move_time: float = 0.0

var shooting_cooldown: float = 3.0 # Time it takes before it goes back into being idle again
var shooting_time: float = 0.0

var small_clock_spinner: Resource = preload("res://GameObjects/Bosses/Clock/SmallClockSpinner.tscn")
var clock_spinner: Resource = preload("res://GameObjects/Bosses/Clock/ClockSpinner.tscn")
var medium_clock_spinner: Resource = preload("res://GameObjects/Bosses/Clock/MediumClockSpinner.tscn")
var big_clock_spinner: Resource = preload("res://GameObjects/Bosses/Clock/BigClockSpinner.tscn")

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
		States.SHOOTING: # Goes into shooting state once it shoots clocks. When it does that, it will wait and then go back to idle state in this logic below.
			shooting_time += delta
			
			if shooting_time >= shooting_cooldown:
				shooting_time = 0.0
				set_idle()

func set_idle() -> void:
	if state != States.DISABLED:
		state = States.IDLE

func set_moving() -> void:
	state = States.MOVING
	$TeleportAnimation.play("Teleport")

func set_shooting() -> void:
	state = States.SHOOTING

func set_new_marker() -> void:
	position_index += 1
	
	# position_index % 3 basically, which loops from 0, 1, and 2
	new_marker = get_tree().get_nodes_in_group("BossPosition")[position_index % get_tree().get_node_count_in_group("BossPosition")]

# current_position is either 0, 1, or 2
func get_random_projectile_position(current_position: int) -> Vector2:
	match current_position:
		0: # Left location
			return Vector2(-390, randf_range(-90, 190)) + Vector2(randf_range(-40, 10), 0)
		1: # Top Location
			return Vector2(randf_range(-340, 150), -119) + Vector2(0, randf_range(-40, 10))
		2: # Right Location
			return Vector2(200, randf_range(-90, 190)) + Vector2(randf_range(-10, 40), 0)
	
	print("ERROR: current_position of get_random_projectile_position is not a valid number!")
	return Vector2.ZERO

# ====================================== METHODS CALLED BY ANIMATIONPLAYER ================================

# This will be called by the DeathAnimation
func visit_new_marker() -> void:
	set_new_marker()
	global_position = new_marker.global_position

# This will be called by the DeathAnimation
func summon_clocks() -> void:
	var direction_to_shoot: Vector2
	var current_position: int = position_index % get_tree().get_node_count_in_group("BossPosition")
	
	match current_position:
		0: # Left location
			direction_to_shoot = Vector2.RIGHT
		1: # Top Location
			direction_to_shoot = Vector2.DOWN
		2: # Right Location
			direction_to_shoot = Vector2.LEFT
	
	for i in range(2):
		var big_spinner_instance: ClockSpinner = big_clock_spinner.instantiate()
		big_spinner_instance.set_direction(direction_to_shoot)
		big_spinner_instance.global_position = get_random_projectile_position(current_position)
		get_parent().add_child(big_spinner_instance)
	
	for i in range(2):
		var medium_spinner_instance: ClockSpinner = medium_clock_spinner.instantiate()
		medium_spinner_instance.set_direction(direction_to_shoot)
		medium_spinner_instance.global_position = get_random_projectile_position(current_position)
		get_parent().add_child(medium_spinner_instance)
	
	for i in range(2):
		var spinner_instance: ClockSpinner = clock_spinner.instantiate()
		spinner_instance.set_direction(direction_to_shoot)
		spinner_instance.global_position = get_random_projectile_position(current_position)
		get_parent().add_child(spinner_instance)
	
	for i in range(4):
		var small_spinner_instance: ClockSpinner = small_clock_spinner.instantiate()
		small_spinner_instance.set_direction(direction_to_shoot)
		small_spinner_instance.global_position = get_random_projectile_position(current_position)
		get_parent().add_child(small_spinner_instance)
	
	
	set_shooting() # This is so that there is some wait time before it swithces back to an idle state.

# ====================================== SIGNAL METHODS =================================

func _on_intro_timeout() -> void:
	set_moving()
