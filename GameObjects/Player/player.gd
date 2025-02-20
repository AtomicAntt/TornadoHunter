class_name Player
extends CharacterBody2D

enum States {NORMAL, DEAD, DASHING}
var state: States = States.NORMAL

@export var SPEED: float = 200.0
#@export var max_lives: int = 10
#@export var lives: int = 6

var dagger: Resource = preload("res://GameObjects/Items/Dagger.tscn")
var shield: Resource = preload("res://GameObjects/Items/Shield.tscn")
var tumbleweed_weapon: Resource = preload("res://GameObjects/Items/TumbleweedDagger.tscn")
var tornado_weapon: Resource = preload("res://GameObjects/Items/TornadoDagger.tscn")
var time_shield: Resource = preload("res://GameObjects/Items/TimeShield.tscn")
var sword: Resource = preload("res://GameObjects/Items/Sword.tscn")
var fire_blade: Resource = preload("res://GameObjects/Items/FlameSword.tscn")

# This bool is set false after ready function, so after initializing
var initializing: bool = true # Purpose: so that the item drop sound does not play when the player is given all the items after each new scene.

# Remember, the invulnerability is set false and true by the AnimationPlayer
var invulnerable: bool = false

func restore_items() -> void:
	if Global.special_weapon_count >= 1:
		var tumbleweed_dagger_instance = tumbleweed_weapon.instantiate()
		add_item_orbit(tumbleweed_dagger_instance)
		$WeaponActivator.visible = true
	
	if Global.special_weapon_count >= 2:
		var tornado_dagger_instance = tornado_weapon.instantiate()
		add_item_orbit(tornado_dagger_instance)
	
	if Global.special_weapon_count >= 3:
		var time_shield_instance = time_shield.instantiate()
		add_item_orbit(time_shield_instance)
	
	for weapon_name: String in Global.weapon_stack:
		match weapon_name:
			"Dagger":
				var weapon_instance = dagger.instantiate()
				add_item_orbit(weapon_instance)
			"Sword":
				var weapon_instance = sword.instantiate()
				add_item_orbit(weapon_instance)
			"FireBlade":
				var weapon_instance = fire_blade.instantiate()
				add_item_orbit(weapon_instance)
	
	#Global.weapon_stack.clear()
	#for i in range(Global.sword_count):
		#var sword_instance = sword.instantiate()
		#add_item_orbit(sword_instance)
	#
	#for i in range(Global.fire_blade_count):
		#var fire_blade_instance = fire_blade.instantiate()
		#add_item_orbit(fire_blade_instance)
	#
	#for i in range(Global.weapon_count):
		#var dagger_instance = dagger.instantiate()
		#add_item_orbit(dagger_instance)
	#
	for i in range(Global.shield_count):
		var shield_instance = shield.instantiate()
		add_item_orbit(shield_instance)

func _ready() -> void:
	var hearts_container: HeartsContainer = get_tree().get_nodes_in_group("HeartsContainer")[0]
	if is_instance_valid(hearts_container):
		hearts_container.update_hearts(Global.health)
	
	restore_items()
		
	initializing = false

func _physics_process(_delta: float) -> void:
	move_and_slide()
	
	match state:
		States.NORMAL:
			get_basic_movement()
			if velocity.length() > 0.0:
				look_at_position(velocity.normalized())
			#check_dash()
			
			#if Input.is_action_pressed("fire"):
				#$AnimatedSprite2D.play("Turn")
		States.DEAD:
			velocity = Vector2.ZERO
		#States.DASHING:
			#
			## This is called, however, it normally transitions out when the roll animation is finished.
			#if !$AnimatedSprite2D.animation == "Roll":
				#state = States.NORMAL
				#velocity = Vector2.ZERO
				#
			## By the time the rolling animation is halfway through, the distance is already traveled visually in the animation, so no more velocity.
			#if $AnimatedSprite2D.frame >= 9:
				#velocity = Vector2.ZERO
				#get_basic_movement()
				#if velocity.length() > 0: # Looks like the player started moving after checking their input! Lets get them back to normal state.
					#state = States.NORMAL


func get_basic_movement() -> void:
	velocity = Vector2.ZERO
	
	if Input.is_action_pressed("right"):
		velocity.x = 1
	if Input.is_action_pressed("left"):
		velocity.x = -1
	if Input.is_action_pressed("up"):
		velocity.y = -1
	if Input.is_action_pressed("down"):
		velocity.y = 1
	
	if state != States.DASHING:
		if velocity.length() > 0.0:
			$AnimatedSprite2D.play("Run")
		else:
			$AnimatedSprite2D.play("Idle")
	
	var speed_multiplier: float = 1.0
	
	if Input.is_action_pressed("fire"):
		#$AnimatedSprite2D.play("Turn")
		speed_multiplier = 0.5
		
	velocity = velocity.normalized() * SPEED * speed_multiplier

func look_at_position(pos: Vector2) -> void:
	#var pos: Vector2 = get_local_mouse_position()
	if pos.x < 0.0:
		$AnimatedSprite2D.flip_h = true
	else:
		$AnimatedSprite2D.flip_h = false

#func check_dash() -> void:
	#if Input.is_action_just_pressed("dash") && velocity.length() > 0.0:
		#velocity = velocity.normalized() * SPEED * 2
		#$AnimatedSprite2D.play("Roll")
		#look_at_position(velocity.normalized())
		#state = States.DASHING

func _on_animated_sprite_2d_animation_finished() -> void:
	if $AnimatedSprite2D.animation == "Roll":
		state = States.NORMAL
		velocity = Vector2.ZERO

func add_item_orbit(item: Area2D):
	var normal_weapon_count: int = 0
	for i in $Orbitor2.get_children():
		if i.is_in_group("weapon") and not i.is_in_group("BossItem"):
			normal_weapon_count += 1
	
	# 2 * pi * r / 50
	if item.is_in_group("weapon"):
		if normal_weapon_count < 6 or item.is_in_group("BossItem"):
			#$Orbitor2.call_deferred("add_child", item)
			$Orbitor2.add_child(item)
		elif $Orbitor3.get_child_count() < 12:
			#$Orbitor3.call_deferred("add_child", item)
			$Orbitor3.add_child(item)
		elif $Orbitor4.get_child_count() < 16:
			$Orbitor4.add_child(item)
		else:
			if item is PlayerWeapon:
				var player_weapon: PlayerWeapon = item
				Global.add_gold(player_weapon.sell_value)
	elif item.is_in_group("shield"):
		#$Orbitor1.call_deferred("add_child", item)
		$Orbitor1.add_child(item)
	
	if not initializing:
		if item.is_in_group("BossItem"):
			$GetBossItem.play()
			$WeaponActivator.visible = true
		else:
			$GetItem.play()

func hurt(damage: int):
	if !invulnerable and state != States.DEAD:
		Global.health -= damage
		$AnimationPlayer.play("Hurt")
		
		var camera_shaker: CameraShaker = get_tree().get_nodes_in_group("Camera")[0]
		if is_instance_valid(camera_shaker):
			if damage > 1:
				$Hurt.play()
				camera_shaker.apply_noise_shake()
			else:
				$Hit.play()
				camera_shaker.apply_medium_shake()
		
		var hearts_container: HeartsContainer = get_tree().get_nodes_in_group("HeartsContainer")[0]
		if is_instance_valid(hearts_container):
			hearts_container.update_hearts(Global.health)
		
		if Global.health <= 0:
			death()

func death() -> void:
	state = States.DEAD
	$Lose.play()
	$AnimatedSprite2D.play("Lose")

	for boss: Boss in get_tree().get_nodes_in_group("Boss"):
		boss.set_disabled()

	for orbitor in get_children():
		if orbitor.is_in_group("orbitor"):
			for child: Area2D in orbitor.get_children():
				child.queue_free()
	
	var main: Main = get_tree().get_nodes_in_group("Main")[0]
	main.level_fail()
	
func set_invulnerable() -> void:
	invulnerable = true

func set_vulnerable() -> void:
	invulnerable = false

func is_invulnerable() -> bool:
	return invulnerable

func get_coin() -> void:
	$GetCoin.play()
	#$GetCoin.set_pitch_scale(randf_range(0.9, 1.1))

func update_weapon_stack() -> void:
	Global.weapon_stack.clear()
	
	var weapons_list: Array[String] = ["Dagger", "Sword", "FireBlade"]
	var orbit_list: Array[Orbitor] = [$Orbitor2, $Orbitor3, $Orbitor4]
	
	for current_orbitor: Orbitor in orbit_list:
		for item in current_orbitor.get_children():
			if not item.is_in_group("BossItem"):
				for weapon_name: String in weapons_list:
					if item.is_in_group(weapon_name):
						print(weapon_name)
						Global.weapon_stack.append(weapon_name)
