class_name ClockBoss
extends Boss

var position_index: int = 0 # Basically this loops through the positions of 0, 1, and 2 using the modulo operator
var attack_index: int = 0 # Basically this loops through the positions of 0 and 1 using the modulo operator

var new_marker: Marker2D

var move_cooldown: float = 2.0 # Time it takes before it takes an action and gets out of idle state
var move_time: float = 0.0

var shooting_cooldown: float = 3.0 # Time it takes before it goes back into being idle again
var shooting_time: float = 0.0

var fire_cooldown: float = 0.25 # Time it takes to fire a spinning clock projectile
var fire_time: float = 0.0

var special_cooldown: float = 2.0
var special_time: float = 0.0

var special_attack_time: float = 0.0 # The cooldown will be calculated by special_cooldown / summon_amount. Ex.: If there is 9 to be summoned, it takes only 1/3 seconds to summon one.

var summon_amount: int = 3
var max_amount: int = 9

var small_clock_spinner: Resource = preload("res://GameObjects/Bosses/Clock/SmallClockSpinner.tscn")
var clock_spinner: Resource = preload("res://GameObjects/Bosses/Clock/ClockSpinner.tscn")
var medium_clock_spinner: Resource = preload("res://GameObjects/Bosses/Clock/MediumClockSpinner.tscn")
var big_clock_spinner: Resource = preload("res://GameObjects/Bosses/Clock/BigClockSpinner.tscn")

var hour_glass: Resource = preload("res://GameObjects/Bosses/Clock/hourglass.tscn")

func _physics_process(delta: float) -> void:
	var _delta: float = delta * Global.time_scale
	
	match state:
		States.IDLE:
			if $Intro.is_stopped():
				move_time += _delta
			
			if move_time >= move_cooldown:
				set_moving()
		States.MOVING: # This state is done as an intermission to the shooting state. When the animationplayer for this finishes, it will switch to the shooting state.
			pass
		States.SHOOTING: # It can go into shooting state after it teleports and the warning was given in the TeleportAnimation animation player ("Teleport").
			shooting_time += _delta
			fire_time += _delta
			
			if fire_time >= fire_cooldown:
				fire_time = 0.0
				summon_clock()
			
			if shooting_time >= shooting_cooldown:
				set_idle()
		States.SPECIAL: # It can go into the special state after it teleports and warning was given in the TeleportAnimation animation player ("TeleportSpecial").
			special_time += _delta
			special_attack_time += _delta
			
			# Ex.: If there is 9 to be summoned, it takes only 1/3 seconds to summon one.
			if special_attack_time >= (special_cooldown / summon_amount): 
				special_attack_time = 0.0
				summon_hourglass()
			
			if special_time >= special_cooldown:
				set_idle()

func set_idle() -> void:
	if state != States.DISABLED:
		state = States.IDLE
		
		# Reset the times needed to switch to idle and to shoot a clock projectile.
		shooting_time = 0.0
		fire_time = 0.0
		
		special_attack_time = 0.0
		special_time = 0.0

func set_moving() -> void:
	state = States.MOVING
	move_time = 0.0 # Reset time needed to enter the moving state from idle state.
	
	if attack_index % 2 == 0:
		$TeleportAnimation.play("Teleport")
	else:
		$TeleportAnimation.play("TeleportSpecial")
	
	attack_index += 1

func set_new_marker() -> void:
	position_index += 1
	
	# position_index % 3 basically, which loops from 0, 1, and 2
	new_marker = get_tree().get_nodes_in_group("ClockPosition")[position_index % get_tree().get_node_count_in_group("ClockPosition")]

# current_position is either 0, 1, or 2
func get_random_projectile_position(current_position: int) -> Vector2:
	match current_position:
		0: # Left location
			return Vector2(-390, randf_range(-90, 190))# + Vector2(randf_range(-40, 10), 0)
		1: # Top Location
			return Vector2(randf_range(-340, 150), -119)# + Vector2(0, randf_range(-40, 10))
		2: # Right Location
			return Vector2(200, randf_range(-90, 190))# + Vector2(randf_range(-10, 40), 0)
	
	print("ERROR: current_position of get_random_projectile_position is not a valid number!")
	return Vector2.ZERO

func get_random_position_around(node: Node2D, min_distance: float = 200) -> Vector2:
	var random_angle = randf() * TAU # Random angle in radians
	var random_distance = randf_range(min_distance, min_distance + 100) # Random distance beyond min_distance
	var offset = Vector2(cos(random_angle), sin(random_angle)) * random_distance
	return node.global_position + offset

func summon_hourglass() -> void:
	var random_offsetX: float = randf_range(-4, 4)
	var random_offsetY: float = randf_range(-4, 4)
	
	var random_position: Vector2 = get_random_position_around(self, 48) + Vector2(random_offsetX, random_offsetY)
	
	var minion_instance: Minion = hour_glass.instantiate()
	minion_instance.global_position = random_position
	get_parent().add_child(minion_instance)
	
	$HourglassSpawn.play()

func summon_clock() -> void:
	var direction_to_shoot: Vector2
	var current_position: int = position_index % get_tree().get_node_count_in_group("ClockPosition")
	
	match current_position:
		0: # Left location
			direction_to_shoot = Vector2.RIGHT
		1: # Top Location
			direction_to_shoot = Vector2.DOWN
		2: # Right Location
			direction_to_shoot = Vector2.LEFT
	
	var random_float = randf()
	if random_float < 0.1:
		var big_spinner_instance: ClockSpinner = big_clock_spinner.instantiate()
		big_spinner_instance.set_direction(direction_to_shoot)
		big_spinner_instance.global_position = get_random_projectile_position(current_position)
		get_parent().add_child(big_spinner_instance)
	elif random_float < 0.2:
		var medium_spinner_instance: ClockSpinner = medium_clock_spinner.instantiate()
		medium_spinner_instance.set_direction(direction_to_shoot)
		medium_spinner_instance.global_position = get_random_projectile_position(current_position)
		get_parent().add_child(medium_spinner_instance)
	elif random_float < 0.5:
		var spinner_instance: ClockSpinner = clock_spinner.instantiate()
		spinner_instance.set_direction(direction_to_shoot)
		spinner_instance.global_position = get_random_projectile_position(current_position)
		get_parent().add_child(spinner_instance)
	elif random_float >= 0.5 and random_float <= 1.0:
		var small_spinner_instance: ClockSpinner = small_clock_spinner.instantiate()
		small_spinner_instance.set_direction(direction_to_shoot)
		small_spinner_instance.global_position = get_random_projectile_position(current_position)
		get_parent().add_child(small_spinner_instance)
	else:
		print("ERROR: could not spawn a clock instance.")


# ====================================== METHODS CALLED BY ANIMATIONPLAYER ================================

# This will be called by TeleportAnimation
func visit_new_marker() -> void:
	set_new_marker()
	global_position = new_marker.global_position

# This will be called by TeleportAnimation
func create_warning() -> void:
	var current_position: int = position_index % get_tree().get_node_count_in_group("ClockPosition")
	var point_position_1: Vector2
	var point_position_2: Vector2
	
	match current_position:
		0: # Left location
			point_position_1 = Vector2(-390, -90)
			point_position_2 = Vector2(-390, 190)
		1: # Top Location
			point_position_1 = Vector2(-340, -119)
			point_position_2 = Vector2(150, -119)
		2: # Right Location
			point_position_1 = Vector2(200, -90)
			point_position_2 = Vector2(200, 190)
	
	$Node/Line2D.set_point_position(0, point_position_1)
	$Node/Line2D.set_point_position(1, point_position_2)
	$Node/Line2D.visible = true
	
	$Node/Line2D/AnimationPlayer.play("Warning")
	
	$Warning.play()

# This will be called by TeleportAnimation
func set_shooting() -> void:
	state = States.SHOOTING
	$ClockSpawn.play()
	
	# Hide the warnings
	$Node/Line2D/AnimationPlayer.stop()
	$Node/Line2D.visible = false
	
# ----------------- SPECIAL ATTACK ----------------

# This will be called by TeleportAnimation ("TeleportSpecial")
func set_special() -> void:
	state = States.SPECIAL

# ====================================== SIGNAL METHODS =================================

func _on_intro_timeout() -> void:
	set_moving()
