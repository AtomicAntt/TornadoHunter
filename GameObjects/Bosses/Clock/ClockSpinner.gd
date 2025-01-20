extends Node2D

@export var hour_rotation_speed: float = 20
@export var minute_rotation_speed: float = 100

@onready var hour = $Hour
@onready var minute = $Minute

func _physics_process(delta: float) -> void:
	var new_hour_rotation = hour.rotation_degrees + hour_rotation_speed * delta
	hour.rotation_degrees = fmod(new_hour_rotation, 360)
	
	var new_minute_rotation = minute.rotation_degrees + minute_rotation_speed * delta
	minute.rotation_degrees = fmod(new_minute_rotation, 360)
