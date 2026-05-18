extends Control

@onready var hand = $HandPanelContainer/Hand
@onready var handCounter = $HandPanelContainer/HandCounter
var tile_scene = preload("res://scenes/tile.tscn")

func _ready() -> void:
	for i in 7:
		var tile_instance = tile_scene.instantiate()
		hand.add_child(tile_instance)
		await get_tree().create_timer(0.2).timeout
	sort_hand()

func _process(_delta: float) -> void:
	handCounter.text = str(hand.get_child_count()) + "/7"

func sort_hand() -> void:
	var tiles_to_be_sorted = hand.get_children()
	tiles_to_be_sorted.sort_custom(func(a, b): return a.name.naturalnocasecmp_to(b.name) < 0)
	for i in len(tiles_to_be_sorted):
		hand.move_child(tiles_to_be_sorted[i], i)
