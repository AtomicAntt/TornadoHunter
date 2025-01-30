class_name ShopNPC
extends Area2D

var player: Player

func _ready() -> void:
	player = get_tree().get_nodes_in_group("Player")[0]

func _physics_process(delta: float) -> void:
	if is_instance_valid(player):
		if global_position.direction_to(player.global_position).x < 0:
			$AnimatedSprite2D.flip_h = true
		else:
			$AnimatedSprite2D.flip_h = false
	else:
		player = get_tree().get_nodes_in_group("Player")[0]
		
func show_text(new_text: String) -> void:
	#$DialogueBox/RichTextLabel.text = "Dagger\nDamage: [color=red]2[/color]"
	$DialogueBox/RichTextLabel.text = new_text
	$DialogueBox/AnimationPlayer.play("Appear")

func hide_text() -> void:
	$DialogueBox/AnimationPlayer.play_backwards("Appear")
