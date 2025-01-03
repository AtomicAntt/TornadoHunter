extends Area2D

@export var d: float = 0.0
@export var radius: float = 50.0
@export var speed: float = 2.0

func _physics_process(delta: float) -> void:
	d += delta
	
	position = Vector2(
		sin(d * speed) * radius,
		cos(d * speed) * radius
	)
