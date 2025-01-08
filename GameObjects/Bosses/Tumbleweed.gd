extends Boss

enum States {STUNNED, ACCELERATING, CHARGING, IDLE, DEAD}
var state: States = States.STUNNED

var spin_speed: float = 0.0
@export var spin_acceleration: float = 300.0
@export var speed_to_charge: float = 1900.0

@export var speed: float = 1000.0

var warning: Resource = preload("res://GameAssets/Effects/bossWarning.png")
var pre_warning: Resource = preload("res://GameAssets/Effects/bossPreWarning.png")

var tiny_tumbleweed: Resource = preload("res://GameObjects/Bosses/TinyTumbleweed.tscn")

var last_player_direction: Vector2 = Vector2.ZERO

var pre_warning_set: bool = false
var warning_set: bool = false

@export var NUM_RAYS: int = 36
@export var RAY_LENGTH: float = 40
@export var DEGREES: float = 360

var raycasts = []

func _ready() -> void:
	for i in range(NUM_RAYS):
		var raycast = RayCast2D.new()
		raycast.target_position = Vector2(RAY_LENGTH, 0)
		raycast.rotation_degrees = i * (DEGREES / NUM_RAYS)
		$Node.add_child(raycast)
		raycasts.append(raycast)

func _physics_process(delta: float) -> void:
	
	match state:
		States.IDLE:
			pass
		States.ACCELERATING:
			spin_speed += spin_acceleration * delta
			rotation_degrees += spin_speed * delta
			
			while rotation_degrees > 360:
				$Charging.play()
				shoot_random_tumbleweed()
				rotation_degrees -= 360
			
			#if spin_speed >= speed_to_charge * 0.25 and spin_speed <= speed_to_charge * 0.5 and pre_warning_set == false:
				#$Node/Line2D.visible = true
				#pre_warning_set = true
				#$Node/Line2D.texture = pre_warning
			#elif spin_speed > speed_to_charge * 0.5 and pre_warning_set == true:
				#pre_warning_set = false
				#$Node/Line2D.texture = warning
			
			if spin_speed > speed_to_charge * 0.5 && warning_set == false:
				warning_set = true
				$Node/Line2D.visible = true
			
			if spin_speed <= speed_to_charge * 0.75:
				var player: Player = get_tree().get_nodes_in_group("Player")[0]
				if is_instance_valid(player):
					last_player_direction = global_position.direction_to(player.global_position) # Get this to figure out where to charge at, it decides when its 75% done charging
					if last_player_direction.x > 0:
						$Node/Line2D.set_point_position(0, position)
						$Node/Line2D.set_point_position(1, position + (last_player_direction * 1000))
					else:
						$Node/Line2D.set_point_position(1, position)
						$Node/Line2D.set_point_position(0, position + (last_player_direction * 1000))
			elif !$Node/Line2D/AnimationPlayer.is_playing():
				$Node/Line2D/AnimationPlayer.play("Warning")
				$Warning.play()
			
			if spin_speed >= speed_to_charge:
				$Node/Line2D.visible = false
				warning_set = false
				$Node/Line2D/AnimationPlayer.stop()
				state = States.CHARGING
				
		States.CHARGING:
			spin_speed -= spin_acceleration * delta
			rotation_degrees -= spin_speed * delta
			
			while rotation_degrees < -360:
				rotation_degrees += 360
			
			global_position += last_player_direction * speed * delta
		States.STUNNED:
			pass

func _on_intro_timeout() -> void:
	accelerate()

func stun() -> void:
	state = States.STUNNED
	$StunAnimation.visible = true
	$StunAnimation.play("Stunned")

func accelerate() -> void:
	state = States.ACCELERATING
	$StunAnimation.visible = false
	$StunAnimation.stop()

func _on_stun_timer_timeout() -> void:
	accelerate()

func _on_charge_hitbox_body_entered(body: Node2D) -> void:
	if state == States.CHARGING:
		impact(true)

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("PlayerHitbox") and state == States.CHARGING:
		var player: Player = get_tree().get_nodes_in_group("Player")[0]
		if is_instance_valid(player):
			player.hurt(4)
			impact(false)
	
	# REWORK: BOSS CHARGES CANT BE BLOCKED BY SHIELDS, WILL ADD PROJECTILES TO BOSS THAT CAN BE BLOCKED INSTEAD
	#elif area.is_in_group("shield") and state == States.CHARGING:
		#var shield: Shield = area
		#shield.use_shield()
		#impact(false)

func impact(sound: bool) -> void:
	stun()
	spin_speed = 0
	$StunTimer.start()
	if sound:
		$Impact.play()
		
	# then i stand back up
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "rotation_degrees", 0, 0.5)
	
	# lets save this for hard mode
	#for raycast: RayCast2D in raycasts:
		#var direction: Vector2 = Vector2.RIGHT.rotated(raycast.rotation_degrees)
		#var minion_instance: EnemyProjectile = tiny_tumbleweed.instantiate()
		#minion_instance.set_direction(direction)
		#minion_instance.set_speed(50)
		#minion_instance.set_friction(25)
		#minion_instance.global_position = global_position
		#get_parent().call_deferred("add_child", minion_instance)

func shoot_random_tumbleweed() -> void:
	for raycast: RayCast2D in raycasts:
		raycast.global_position = global_position
	
	var available_raycasts: Array[RayCast2D] = []
	for raycast: RayCast2D in raycasts:
		if !raycast.is_colliding():
			available_raycasts.append(raycast)
	
	if available_raycasts.size() > 0:
		var random_raycast = available_raycasts[randi() % available_raycasts.size()]
		
		var direction: Vector2 = Vector2.RIGHT.rotated(random_raycast.rotation)
		
		var minion_instance: EnemyProjectile = tiny_tumbleweed.instantiate()
		minion_instance.set_direction(direction)
		minion_instance.set_speed(randf_range(30.0, 60.0))
		minion_instance.set_friction(randf_range(8.0, 10.0))
		minion_instance.set_time(60.0)
		minion_instance.global_position = global_position
		get_parent().call_deferred("add_child", minion_instance)

# to be unused :(
func spawn_static_tumbleweed() -> void:
	var minion_instance: EnemyProjectile = tiny_tumbleweed.instantiate()
	minion_instance.set_speed(0)
	minion_instance.global_position = global_position
	get_parent().call_deferred("add_child", minion_instance)
