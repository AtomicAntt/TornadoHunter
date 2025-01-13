extends Node

var gold: int
var weapon_count: int = 3
var shield_count: int = 1

signal update_gold

func add_gold(amount: int) -> void:
	gold += amount
	update_gold.emit(gold)
