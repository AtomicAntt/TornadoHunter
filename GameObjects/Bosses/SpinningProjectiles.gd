class_name SpinningWind
extends Node2D

# https://github.com/GameEndeavor/platformer-tutorials/blob/master/rotating-platforms/OrbitingPlatformsController.gd

@export var radius = Vector2.ONE * 256 # Distance on the x and y axis to orbit around the controller
@export var rotation_duration := 4.0 # How many seconds it takes for one platform to complete one rotation

var platforms = [] # References to the platforms that will orbit controller
var orbit_angle_offset = 0 # Angle that first platform will orbit around controller
var prev_child_count = 0 # How many children this controller had, used to check if new children added or removed

var direction: Vector2 = Vector2.ZERO
var speed: float = 100.0

func set_direction(new_direction: Vector2) -> void:
	direction = new_direction
	
func _ready() -> void:
	if prev_child_count != get_child_count():
		# Update the variable for checking and reset platform references
		prev_child_count = get_child_count()
		_find_platforms()

func _physics_process(delta):
	# Increment the angle so that it completes one full rotation in the given number of seconds.
	# TODO: If you intend to use a speed of zero, then you may want to add a zero check here
	orbit_angle_offset += 2 * PI * delta / float(rotation_duration)
	# Wrap the angle to keep it nice and tidy, and to prevent unlikely overflow
	orbit_angle_offset = wrapf(orbit_angle_offset, -PI, PI)
	# Update platform positions
	_update_platforms()
	
	global_position += direction * speed * delta

# Updates platform positions by determining how far they should orbit from each other
func _update_platforms():
	# Don't create black holes
	if platforms.size() != 0:
		# Get the spacing by diving a full circle by the number of platforms in controller
		var spacing = 2 * PI / float(platforms.size())
		# Iterate through all references of the platforms
		for i in platforms.size():
			# Create an empty Vector2 since we have to update the platforms position at once
			# instead of one axis at a time, due to sync_to_physics being enabled.
			var new_position = Vector2()
			# Bit of trig to determine where the platform should be
			# `spacing * i` spreads the platforms out based on their iteration
			# `orbit_angle_offset` is where the first platform should be
			# `radius` moves the platforms away from the controller.
			new_position.x = cos(spacing * i + orbit_angle_offset) * radius.x
			new_position.y = sin(spacing * i + orbit_angle_offset) * radius.y
			if is_instance_valid(platforms[i]):
				platforms[i].position = new_position

# Iterates through the children of this node, finding all platforms in the `platforms` group.
func _find_platforms():
	# Reset the array, otherwise we'll just keep piling on platforms
	platforms = []
	for child in get_children():
		if child.is_in_group("EnemyAttack"):
			platforms.append(child)

func _on_expiration_timer_timeout() -> void:
	queue_free()
