extends Node

var gold: int

signal update_gold

func add_gold(amount: int) -> void:
	gold += amount
	update_gold.emit(gold)
