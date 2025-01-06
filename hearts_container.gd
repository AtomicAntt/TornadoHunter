class_name HeartsContainer
extends HBoxContainer

# https://kidscancode.org/godot_recipes/3.x/ui/heart_containers_3/index.html

var heart_full: Resource = preload("res://GameAssets/UI/HealthBar/heart.png")
var heart_half: Resource = preload("res://GameAssets/UI/HealthBar/halfHeart.png")
var heart_empty: Resource = preload("res://GameAssets/UI/HealthBar/emptyHeart.png")

func update_hearts(value: int) -> void:
	for i in get_child_count():
		if value > i * 2 + 1:
			get_child(i).texture = heart_full
		elif value > i * 2:
			get_child(i).texture = heart_half
		else:
			get_child(i).texture = heart_empty
	
