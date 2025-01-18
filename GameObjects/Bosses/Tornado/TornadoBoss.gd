extends Boss

var spinning_wind: Resource = preload("res://GameObjects/Bosses/Tornado/SpinningWind.tscn")
var wind_attack: Resource = preload("res://GameObjects/Bosses/Tornado/TornadoWind.tscn")

# Specifically, this is for the spiral attack
var attack_cooldown: float = 0.1
var attack_time: float = 0.0

# This is for when the boss is in idle, how much time needed until charging again?
var charge_cooldown: float = 2.0
var charge_time: float = 0.0

var rotation_speed: float = 100
var spawn_point_count: int = 4
var radius: float = 10

var speed: float = 100

var movement_tween: Tween

var position_index: int = 0 # Basically this loops through the positions of 0, 1, and 2 using the modulo operator
var new_marker: Marker2D

func _ready() -> void:
	var step: float = 2 * PI / spawn_point_count
	
	for i in range(spawn_point_count):
		var spawn_point: Node2D = Node2D.new()
		var pos: Vector2 = Vector2(radius, 0).rotated(step * i)
		spawn_point.position = pos
		spawn_point.rotation = pos.angle()
		$Rotater.add_child(spawn_point)

func _physics_process(delta: float) -> void:
	var new_rotation = $Rotater.rotation_degrees + rotation_speed * delta
	$Rotater.rotation_degrees = fmod(new_rotation, 360)
	
	match state:
		States.IDLE:
			charge_time += delta
			if charge_time >= charge_cooldown:
				charge_time = 0.0
				set_accelerating()
		States.ACCELERATING:
			pass
		States.CHARGING:
			attack_time += delta
			if attack_time >= attack_cooldown:
				attack_time = 0.0
				shoot_spiral()
			
			if is_instance_valid(movement_tween):
				if not movement_tween.is_running():
					set_idle()

func _on_intro_timeout() -> void:
	set_accelerating()

func shoot_spinning_wind() -> void:
	var player: Player = get_tree().get_nodes_in_group("Player")[0]
	var direction_to_player: Vector2 = global_position.direction_to(player.global_position)
	
	var wind_instance: SpinningWind = spinning_wind.instantiate()
	wind_instance.set_direction(direction_to_player)
	wind_instance.global_position = global_position
	get_parent().call_deferred("add_child", wind_instance)

func shoot_spiral() -> void:
	for s: Node2D in $Rotater.get_children():
		var wind_instance: EnemyProjectile = wind_attack.instantiate()
		wind_instance.global_position = s.global_position
		wind_instance.set_direction(Vector2.RIGHT.rotated(s.global_rotation))
		wind_instance.set_speed(80)
		get_parent().add_child(wind_instance)

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("PlayerHitbox"):
		var player: Player = get_tree().get_nodes_in_group("Player")[0]
		if is_instance_valid(player):
			if !player.is_invulnerable():
				player.hurt(1)

func set_accelerating() -> void:
	state = States.ACCELERATING
	set_new_marker()

	if global_position.direction_to(new_marker.global_position).x < 0:
		$Node/Line2D.set_point_position(1, position)
		$Node/Line2D.set_point_position(0, new_marker.global_position)
	else:
		$Node/Line2D.set_point_position(0, position)
		$Node/Line2D.set_point_position(1, new_marker.global_position)
	
	$Node/Line2D.visible = true
	$Node/Line2D/AnimationPlayer.play("Warning")
	$Warning.play()
	
	await get_tree().create_timer(1.0).timeout
	
	$Node/Line2D.visible = false
	$Node/Line2D/AnimationPlayer.stop()
	set_charging()

func set_charging() -> void:
	state = States.CHARGING
	charge_time = 0
	
	visit_new_marker()

func set_new_marker() -> void:
	position_index += 1
	
	# position_index % 3 basically, which loops from 0, 1, and 2
	new_marker = get_tree().get_nodes_in_group("BossPosition")[position_index % get_tree().get_node_count_in_group("BossPosition")]

func visit_new_marker() -> void:
	#position_index += 1
	#var new_marker: Marker2D
	#
	## position_index % 3 basically, which loops from 0, 1, and 2
	#new_marker = get_tree().get_nodes_in_group("BossPosition")[position_index % get_tree().get_node_count_in_group("BossPosition")]
	
	if is_instance_valid(new_marker):
		movement_tween = get_tree().create_tween()
		movement_tween.tween_property(self, "global_position", new_marker.global_position, global_position.distance_to(new_marker.global_position) / speed)

func set_idle() -> void:
	state = States.IDLE
	attack_time = 0
