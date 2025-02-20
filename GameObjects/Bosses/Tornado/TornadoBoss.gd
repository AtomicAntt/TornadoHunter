extends Boss

var spinning_wind: Resource = preload("res://GameObjects/Bosses/Tornado/SpinningWind.tscn")
var wind_attack: Resource = preload("res://GameObjects/Bosses/Tornado/TornadoWind.tscn")
var flying_debris: Resource = preload("res://GameObjects/Bosses/Tornado/FlyingDebris.tscn")

# Specifically, this is for the spiral attack
var attack_cooldown: float = 0.1
var attack_time: float = 0.0

# This is for when the boss is in idle, how much time needed until charging again? (charging means either moving somewhere or shooting some debris)
var charge_cooldown: float = 1.5
var charge_time: float = 0.0

var rotation_speed: float = 100
var spawn_point_count: int = 4
var radius: float = 10

var speed: float = 100

var movement_tween: Tween

var position_index: int = 2 # Basically this loops through the positions of 0, 1, and 2 using the modulo operator
var attack_index: int = 0 # Basically this loops through attack 0 or 1
var new_marker: Marker2D

var aim_marker: bool = false # Before throwing the collected debris, this bool is set true until it is 1 second before the actual warning

func _ready() -> void:
	var step: float = 2 * PI / spawn_point_count
	
	for i in range(spawn_point_count):
		var spawn_point: Node2D = Node2D.new()
		var pos: Vector2 = Vector2(radius, 0).rotated(step * i)
		spawn_point.position = pos
		spawn_point.rotation = pos.angle()
		$Rotater.add_child(spawn_point)

func _physics_process(delta: float) -> void:
	var _delta = delta * Global.time_scale
	
	var new_rotation = $Rotater.rotation_degrees + rotation_speed * _delta
	$Rotater.rotation_degrees = fmod(new_rotation, 360)
	
	if is_instance_valid(movement_tween):
		movement_tween.set_speed_scale(Global.time_scale)
	$AnimatedSprite2D.speed_scale = Global.time_scale
	
	match state:
		States.IDLE:
			if $Intro.is_stopped():
				charge_time += _delta
			
			if charge_time >= charge_cooldown:
				charge_time = 0.0
				#set_accelerating()
				if attack_index % 2 == 1:
					attack_index += 1
					set_accelerating()
				else:
					attack_index += 1
					$SpecialAttackSignal.play()
					special_attack()
		States.ACCELERATING:
			pass
		States.CHARGING:
			attack_time += _delta
			if attack_time >= attack_cooldown:
				attack_time = 0.0
				shoot_spiral()
			
			if is_instance_valid(movement_tween):
				if not movement_tween.is_running():
					set_idle()
		States.SPECIAL:
			if get_tree().get_node_count_in_group("Debris") <= 0:
				shoot_debris()
		States.SHOOTING:
			if aim_marker:
				var player: Player = get_tree().get_nodes_in_group("Player")[0]
				var last_player_direction = global_position.direction_to(player.global_position)
			
				if last_player_direction.x > 0:
					$Node/Line2D.set_point_position(0, position)
					$Node/Line2D.set_point_position(1, position + (last_player_direction * 1000))
				else:
					$Node/Line2D.set_point_position(1, position)
					$Node/Line2D.set_point_position(0, position + (last_player_direction * 1000))
			

func _on_intro_timeout() -> void:
	set_accelerating()
	#special_attack()
	#attack_index += 1

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
	if area.is_in_group("PlayerHitbox") and state != States.DISABLED:
		var player: Player = get_tree().get_nodes_in_group("Player")[0]
		if is_instance_valid(player):
			if !player.is_invulnerable():
				if state == States.CHARGING:
					player.hurt(2)
				else:
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
	if state != States.DISABLED:
		state = States.CHARGING
		charge_time = 0
		$TornadoMove.play()
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
		movement_tween.tween_property(self, "global_position", new_marker.global_position, global_position.distance_to(new_marker.global_position) / speed).set_trans(Tween.TRANS_CUBIC)

func set_idle() -> void:
	if state != States.DISABLED:
		state = States.IDLE
		attack_time = 0

# Start gathering up debris
func special_attack() -> void:
	if state != States.DISABLED:
		spawn_debris()
		state = States.SPECIAL

func spawn_debris() -> void:
	var spinning_wind_instance: SpinningWind = spinning_wind.instantiate()
	spinning_wind_instance.global_position = global_position
	get_parent().add_child(spinning_wind_instance)
	
	var second_instance: SpinningWind = spinning_wind.instantiate()
	second_instance.global_position = global_position
	second_instance.radius.x = 40
	second_instance.radius.y = 40
	get_parent().add_child(second_instance)
	
	#for i in range(debris_count):
		#var random_offsetX: float = randf_range(150, 300)
		#var random_offsetY: float = randf_range(150, 300)
		#var random_multiplierX: int
		#var random_multiplierY: int
		#
		#if randf() < 0.5:
			#random_multiplierX = -1
		#else:
			#random_multiplierX = 1
		#
		#if randf() < 0.5:
			#random_multiplierY = -1
		#else:
			#random_multiplierY = 1
		#
		#random_offsetX *= random_multiplierX
		#random_offsetY *= random_multiplierY
		#
		#var debris_instance: FlyingDebris = flying_debris.instantiate()
		#debris_instance.global_position = Vector2(random_offsetX, random_offsetY)
		#get_parent().add_child(debris_instance)

func shoot_debris() -> void:
	state = States.SHOOTING
	
	$Node/Line2D.visible = true
	aim_marker = true
	await get_tree().create_timer(1.0).timeout
	aim_marker = false
	
	#var player: Player = get_tree().get_nodes_in_group("Player")[0]
	#var last_player_direction = global_position.direction_to(player.global_position)
	
	for i in range(2):
		var player: Player = get_tree().get_nodes_in_group("Player")[0]
		var last_player_direction = global_position.direction_to(player.global_position)
		
		if last_player_direction.x > 0:
			$Node/Line2D.set_point_position(0, position)
			$Node/Line2D.set_point_position(1, position + (last_player_direction * 1000))
		else:
			$Node/Line2D.set_point_position(1, position)
			$Node/Line2D.set_point_position(0, position + (last_player_direction * 1000))
		
		$Node/Line2D.visible = true
		$Node/Line2D/AnimationPlayer.play("Warning")
		$Warning.play()
		
		await get_tree().create_timer(1.0).timeout
		
		$Node/Line2D.visible = false
		$Node/Line2D/AnimationPlayer.stop()
		$Warning.stop()
		
		for wind_instance: SpinningWind in get_tree().get_nodes_in_group("SpinningWind"): 
			if not wind_instance.attacked:
				wind_instance.attack(last_player_direction)
				$TornadoThrow.play()
				var camera_shaker: CameraShaker = get_tree().get_nodes_in_group("Camera")[0]
				if is_instance_valid(camera_shaker):
					camera_shaker.apply_medium_shake()
				break
		
		await get_tree().create_timer(1.0).timeout
	
	set_idle()
