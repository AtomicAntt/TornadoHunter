extends Node2D

var rotation_speed: float = 100
var spawn_point_count: int = 4
var radius: float = 10


func _ready() -> void:
	var step: float = 2 * PI / spawn_point_count
	
	for i in range(spawn_point_count):
		var spawn_point: Node2D = Node2D.new()
		var pos: Vector2 = Vector2(radius, 0).rotated(step * i)
		spawn_point.position = pos
		spawn_point.rotation = pos.angle()
		add_child(spawn_point)
