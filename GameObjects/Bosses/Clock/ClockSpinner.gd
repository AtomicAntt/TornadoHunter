class_name ClockSpinner
extends Node2D

@export var hour_rotation_speed: float = 20
@export var minute_rotation_speed: float = 100

@onready var hour = $Hour
@onready var minute = $Minute

var direction: Vector2 = Vector2.ZERO

@export var speed: float = 100

func set_direction(new_direction: Vector2) -> void:
	direction = new_direction

func set_speed(new_speed: float) -> void:
	speed = new_speed
	
func _physics_process(delta: float) -> void:
	var _delta: float = delta * Global.time_scale
	global_position += direction * speed * _delta
	
	var new_hour_rotation = hour.rotation_degrees + hour_rotation_speed * _delta
	hour.rotation_degrees = fmod(new_hour_rotation, 360)
	
	var new_minute_rotation = minute.rotation_degrees + minute_rotation_speed * _delta
	minute.rotation_degrees = fmod(new_minute_rotation, 360)
