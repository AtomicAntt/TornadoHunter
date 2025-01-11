extends Node

var gold: int

signal obtain_gold

func add_gold(amount: int) -> void:
	gold += amount
	obtain_gold.emit()
