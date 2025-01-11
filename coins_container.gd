extends HBoxContainer

@export var duration: float = 0.5

func _ready() -> void:
	Global.update_gold.connect(change_gold)

func change_gold(amount: int) -> void:
	$Label.text = str(amount)
