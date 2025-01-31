extends Node

var gold: int

# We'll update these when the player enters the gate in the shop area (this is because it's after all the purhcasing stuff is done)
var weapon_count: int = 3
var shield_count: int = 1

var sword_count: int = 0
var fire_blade_count: int = 0

var special_weapon_count: int = 0

var health: int = 6

var time_scale: float = 1.0

var items_viewed: Array[String] = []

signal update_gold

func add_gold(amount: int) -> void:
	gold += amount
	update_gold.emit(gold)
