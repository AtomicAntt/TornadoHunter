extends Node

var gold: int

# We'll update these when the player enters the gate in the shop area (this is because it's after all the purhcasing stuff is done)
var weapon_count: int = 3
var shield_count: int = 1

var health: int = 6

signal update_gold

func add_gold(amount: int) -> void:
	gold += amount
	update_gold.emit(gold)
