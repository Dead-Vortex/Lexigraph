extends Control

@onready var hand = $HandPanelContainer/Hand
@onready var handCounter = $HandPanelContainer/HandCounter
@onready var scoreCounter = $ScoreCounter
var tile_scene = preload("res://scenes/tile.tscn")
@onready var word_display = $WordDisplay

var en_dictionary : PackedStringArray

var hand_size : int = 9
var deck = []

var typed_word : String
var played_tiles = []
var hand_score : int = 0
var score: int = 0

func load_dictionary():
	var file = FileAccess.open("res://dictionary.txt", FileAccess.READ)
	var content = file.get_as_text()
	content = content.to_lower()
	en_dictionary = content.split("\n", false)

func in_dictionary(word: String) -> bool:
	var lower_word = word.to_lower()
	if lower_word in en_dictionary and len(lower_word) >= 2:
		return true
	else:
		return false

func _ready() -> void:
	load_dictionary()
	# Create base deck
	for i in 12:
		if i <= 9:
			deck.append(1)
			deck.append(9)
		if i <= 2:
			deck.append(2)
			deck.append(3)
			deck.append(6)
			deck.append(8)
			deck.append(13)
			deck.append(16)
			deck.append(22)
			deck.append(23)
			deck.append(25)
		if i <= 4:
			deck.append(4)
			deck.append(12)
			deck.append(19)
			deck.append(21)
		deck.append(5)
		if i <= 3:
			deck.append(7)
		if i == 1:
			deck.append(10)
			deck.append(11)
			deck.append(17)
			deck.append(24)
			deck.append(26)
		if i <= 6:
			deck.append(14)
			deck.append(18)
			deck.append(20)
		if i <= 8:
			deck.append(15)
	deck.shuffle()
	
	draw_tiles_from_deck(true)
	#for i in hand_size:
		#var chosen_letter = deck.pick_random()
		#deck.remove_at(deck.find(chosen_letter))
		#draw_new_tile(Letters.NUM_TO_LETTER[chosen_letter])
		#await get_tree().create_timer(0.14).timeout
	#print(deck)

func _process(_delta) -> void:
	handCounter.text = str(hand.get_child_count()) + "/" + str(hand_size)

func draw_new_tile(letter = "") -> void:
	var tile_instance = tile_scene.instantiate()
	hand.add_child(tile_instance)
	tile_instance.tile_clicked.connect(_on_tile_clicked)
	if letter != "":
		tile_instance.change_letter(letter)
	sort_hand()
	
func draw_tiles_from_deck(fill_hand: bool = false, count: int = 1, delay: float = 0.14) -> void:
	for i in (hand_size - hand.get_child_count()) if fill_hand else count:
		var tile_instance = tile_scene.instantiate()
		var chosen_letter = deck.pick_random()
		deck.remove_at(deck.find(chosen_letter))
		hand.add_child(tile_instance)
		tile_instance.tile_clicked.connect(_on_tile_clicked)
		tile_instance.change_letter(Letters.NUM_TO_LETTER[chosen_letter])
		sort_hand()
		if count > 1 or fill_hand:
			await get_tree().create_timer(delay).timeout

func sort_hand() -> void:
	var tiles_to_be_sorted = hand.get_children()
	tiles_to_be_sorted.sort_custom(func(a, b): return a.name.naturalnocasecmp_to(b.name) < 0)
	for i in len(tiles_to_be_sorted):
		hand.move_child(tiles_to_be_sorted[i], i)

func _on_tile_clicked(clicked_tile) -> void:
	typed_word += Letters.NUM_TO_LETTER[clicked_tile.letter]
	word_display.text = typed_word + "\n" + str(in_dictionary(typed_word))
	played_tiles.append(clicked_tile)
	hand.remove_child(clicked_tile)

func _on_word_cleared() -> void:
	for i in len(played_tiles):
		hand.add_child(played_tiles[i])
	sort_hand()
	played_tiles = []
	typed_word = ""
	word_display.text = ""

func _on_word_played() -> void:
	if in_dictionary(typed_word):
		hand_score = 0
		for i in len(played_tiles):
			score += played_tiles[i].number
		score += hand_score
		scoreCounter.text = "Score: " + str(score)
		print(hand_score)
		played_tiles = []
		typed_word = ""
		word_display.text = ""
		draw_tiles_from_deck(true)
