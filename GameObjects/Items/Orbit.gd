class_name Orbitor
extends Node2D

# https://github.com/GameEndeavor/platformer-tutorials/blob/master/rotating-platforms/OrbitingPlatformsController.gd

@export var radius = Vector2.ONE * 256
@export var rotation_duration := 4.0 # How many seconds for an item to complete a rotation.
@export var fire_multiplier: float = 6.0

var items = []
var orbit_angle_offset: float = 0
var prev_child_count: int = 0

func _ready() -> void:
	find_items()

func _physics_process(delta: float) -> void:
	# Check if any children added/removed and reset item references
	if prev_child_count != get_child_count():
		prev_child_count = get_child_count()
		find_items()
	
	var multiplier: float = 1.0
	
	if Input.is_action_pressed("fire"):
		multiplier = fire_multiplier
	
	orbit_angle_offset += 2 * PI * delta / float(rotation_duration / multiplier)
	# Wrap the angle to keep it nice and tidy, and to prevent unlikely overflow
	orbit_angle_offset = wrapf(orbit_angle_offset, -PI, PI)
	
	update_items()

func update_items():
	if items.size() != 0:
		# Get the spacing by diving a full circle by the number of items in controller
		var spacing = 2 * PI / float(items.size())
		# Iterate through all references of the items
		for i in items.size():
			# Create an empty Vector2 since we have to update the items position at once
			# instead of one axis at a time, due to sync_to_physics being enabled.
			var new_position = Vector2()
			# Bit of trig to determine where the item should be
			# `spacing * i` spreads the items out based on their iteration
			# `orbit_angle_offset` is where the first item should be
			# `radius` moves the items away from the controller.
			new_position.x = cos(spacing * i + orbit_angle_offset) * radius.x
			new_position.y = sin(spacing * i + orbit_angle_offset) * radius.y
			#if is_instance_valid(items[i]): # Added this because queue_freeing items messed things up
			items[i].position = new_position

func find_items():
	# Reset the array, otherwise we'll just keep piling on items
	items = []
	for child in get_children():
		if child.is_in_group("item"):
			items.append(child)
