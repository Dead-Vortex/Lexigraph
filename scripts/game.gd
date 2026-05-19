extends Control

@onready var hand = $HandPanelContainer/Hand
@onready var handCounter = $HandPanelContainer/HandCounter
var tile_scene = preload("res://scenes/tile.tscn")
@onready var word_display = $WordDisplay

var en_dictionary : PackedStringArray

var typed_word : String

func load_dictionary():
	var file = FileAccess.open("res://dictionary.txt", FileAccess.READ)
	var content = file.get_as_text()
	content = content.to_lower()
	en_dictionary = content.split("\n", false)

func in_dictionary(word: String) -> bool:
	var lower_word = word.to_lower()
	return lower_word in en_dictionary

func _ready() -> void:
	load_dictionary()
	for i in 7:
		draw_new_tile()
		await get_tree().create_timer(0.2).timeout

func _process(_delta) -> void:
	handCounter.text = str(hand.get_child_count()) + "/7"

func draw_new_tile() -> void:
	var tile_instance = tile_scene.instantiate()
	hand.add_child(tile_instance)
	sort_hand()

func sort_hand() -> void:
	var tiles_to_be_sorted = hand.get_children()
	tiles_to_be_sorted.sort_custom(func(a, b): return a.name.naturalnocasecmp_to(b.name) < 0)
	for i in len(tiles_to_be_sorted):
		hand.move_child(tiles_to_be_sorted[i], i)

	#print("d")
	#typed_word += str(letter.name)[0]
	#word_display.text = typed_word
	#letter.queue_free()
