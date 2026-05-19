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

func draw_new_tile(letter = "") -> void:
	var tile_instance = tile_scene.instantiate()
	hand.add_child(tile_instance)
	tile_instance.tile_clicked.connect(_on_tile_clicked)
	if letter != "":
		tile_instance.change_letter(letter)
	sort_hand()

func sort_hand() -> void:
	var tiles_to_be_sorted = hand.get_children()
	tiles_to_be_sorted.sort_custom(func(a, b): return a.name.naturalnocasecmp_to(b.name) < 0)
	for i in len(tiles_to_be_sorted):
		hand.move_child(tiles_to_be_sorted[i], i)

func _on_tile_clicked(clicked_tile) -> void:
	typed_word += Letters.NUM_TO_LETTER[clicked_tile.letter]
	word_display.text = typed_word + "\n" + str(in_dictionary(typed_word))
	clicked_tile.queue_free()

func _on_word_cleared() -> void:
	for i in len(typed_word):
		draw_new_tile(typed_word[i])
	typed_word = ""
	word_display.text = typed_word
