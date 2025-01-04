extends Camera2D

func _physics_process(_delta: float) -> void:
	var pos = get_local_mouse_position()
	if pos.x >= -250 and pos.x < 250:
		set_position(pos)
