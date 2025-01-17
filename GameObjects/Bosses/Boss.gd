class_name Boss
extends Area2D

@export var max_health: float = 100.0
@export var health: float = 100.0

@export var coin_value: int = 5
@export var coin_amount: int = 20

enum States {STUNNED, ACCELERATING, CHARGING, IDLE, DEAD, DISABLED, NORMAL}
var state: States = States.IDLE

var enemy_projectile: Resource = preload("res://GameObjects/Bosses/EnemyProjectile.tscn")
var coin: Resource = preload("res://GameObjects/Items/Coin.tscn")

func set_disabled() -> void:
	print("i am now disabled")
	state = States.DISABLED

func hurt(damage: float) -> void:
	health -= damage
	for bossHealth: BossHealth in get_tree().get_nodes_in_group("BossHealthBar"):
		bossHealth.change_health(max_health, health)
	$AnimationPlayer.play("Hurt")
	$Hurt.play()
	$Hurt.set_pitch_scale(randf_range(0.5, 1.5))
	
	if health <= 0:
		death()

func fire_at_player() -> void:
	var player: Player = get_tree().get_nodes_in_group("Player")[0]
	if is_instance_valid(player):
		var projectile_instance: EnemyProjectile = enemy_projectile.instantiate()
		projectile_instance.set_direction(global_position.direction_to(player.global_position))
		projectile_instance.global_position = global_position
		get_parent().add_child(projectile_instance)

func death() -> void:
	if state != States.DISABLED:
		state = States.DISABLED
		$AnimatedSprite2D.visible = false
		$DeathSprite.visible = true
		
		for enemy_attack: EnemyProjectile in get_tree().get_nodes_in_group("EnemyAttack"):
			enemy_attack.dissolve()
		
		$DeathAnimation.play("Death")
		$Death.play()
		
		for i in range(coin_amount):
			var coin_instance: Coin = coin.instantiate()
			get_parent().call_deferred("add_child", coin_instance)
			coin_instance.global_position = global_position
			coin_instance.explode_outwards()
			coin_instance.set_value(coin_value)
		
		# Later, if there are double bosses, you must check if there are any boss instances left
		var main: Main = get_tree().get_nodes_in_group("Main")[0]
		if is_instance_valid(main):
			main.level_success()
		
		#queue_free()

func _on_timer_timeout() -> void:
	fire_at_player()
