extends Control

@onready var hand = $HandPanelContainer/Hand
@onready var handCounter = $HandPanelContainer/HandCounter

func _process(delta: float) -> void:
	handCounter.text = str(hand.get_child_count()) + "/7"
