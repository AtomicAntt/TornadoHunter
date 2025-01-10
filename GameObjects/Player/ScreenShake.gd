class_name CameraShaker
extends Camera2D

# https://github.com/theshaggydev/the-shaggy-dev-projects/blob/main/projects/godot-3/screen-shake/sample_scene.gd

@export var RANDOM_SHAKE_STRENGTH: float = 30.0
@export var SHAKE_DECAY_RATE: float = 5.0

@export var NOISE_SHAKE_SPEED: float = 30.0
@export var NOISE_SHAKE_STRENGTH: float = 60.0

@export var MEDIUM_SHAKE_SPEED: float = 20.0
@export var MEDIUM_SHAKE_STRENGTH: float = 40.0

@export var WEAK_SHAKE_SPEED: float = 6.0
@export var WEAK_SHAKE_STRENGTH: float = 12.0

@export var SUPER_WEAK_SPEED: float = 6.0
@export var SUPER_WEAK_STRENGTH: float = 3.0

@export var NOISE_SWAY_SPEED: float = 1.0
@export var NOISE_SWAY_STRENGTH: float = 10.0

enum ShakeType {
	RANDOM, NOISE, SWAY, MEDIUM, WEAK, SUPER_WEAK
}

var shake_type: ShakeType = ShakeType.RANDOM

@onready var noise = FastNoiseLite.new()
@onready var rand = RandomNumberGenerator.new()
var noise_i: float = 0.0
var shake_strength: float = 0.0

func _ready() -> void:
	rand.randomize()
	
	noise.seed = rand.randi()
	noise.frequency = 0.5

func apply_random_shake() -> void:
	shake_strength = RANDOM_SHAKE_STRENGTH
	shake_type = ShakeType.RANDOM

func apply_noise_shake() -> void:
	shake_strength = NOISE_SHAKE_STRENGTH
	shake_type = ShakeType.NOISE
	
func apply_medium_shake() -> void:
	shake_strength = MEDIUM_SHAKE_STRENGTH
	shake_type = ShakeType.MEDIUM

func apply_weak_shake() -> void:
	shake_strength = WEAK_SHAKE_STRENGTH
	shake_type = ShakeType.WEAK

func apply_super_weak_shake() -> void:
	shake_strength = SUPER_WEAK_STRENGTH
	shake_type = ShakeType.SUPER_WEAK

func apply_noise_sway() -> void:
	shake_type = ShakeType.SWAY


#func _physics_process(_delta: float) -> void:
	#var pos = get_local_mouse_position()
	#if pos.x >= -250 and pos.x < 250:
		#set_position(pos)

func _process(delta: float) -> void:
	shake_strength = lerpf(shake_strength, 0, SHAKE_DECAY_RATE * delta)
	
	var shake_offset: Vector2
	
	match shake_type:
		ShakeType.RANDOM:
			shake_offset = get_random_offset()
		ShakeType.NOISE:
			shake_offset = get_noise_offset(delta, NOISE_SHAKE_SPEED, shake_strength)
		ShakeType.MEDIUM:
			shake_offset = get_noise_offset(delta, MEDIUM_SHAKE_SPEED, shake_strength)
		ShakeType.WEAK:
			shake_offset = get_noise_offset(delta, WEAK_SHAKE_SPEED, shake_strength)
		ShakeType.SUPER_WEAK:
			shake_offset = get_noise_offset(delta, SUPER_WEAK_SPEED, shake_strength)
		ShakeType.SWAY:
			shake_offset = get_noise_offset(delta, NOISE_SWAY_SPEED, NOISE_SWAY_STRENGTH)
	
	# Shake by adjusting camera.offset so we can move the camera around the level via it's position
	offset = shake_offset

func get_noise_offset(delta: float, speed: float, strength: float) -> Vector2:
	noise_i += delta * speed
	# Set the x values of each call to 'get_noise_2d' to a different value
	# so that our x and y vectors will be reading from unrelated areas of noise
	return Vector2(
		noise.get_noise_2d(1, noise_i) * strength,
		noise.get_noise_2d(100, noise_i) * strength
	)

func get_random_offset() -> Vector2:
	return Vector2(
		rand.randf_range(-shake_strength, shake_strength),
		rand.randf_range(-shake_strength, shake_strength)
	)
