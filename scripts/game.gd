extends Control

@onready var hand = $HandPanelContainer/Hand
@onready var handCounter = $HandPanelContainer/HandCounter
@onready var scoreCounter = $ScoreCounter
var tile_scene = preload("res://scenes/tile.tscn")
@onready var word_display = $WordDisplay
@onready var tile_playmat = $PlayedTiles
@onready var soundplayer = $AudioStreamPlayer
@onready var bonuswordscontainer = $BonusWords
var bonuswordlabelsettings = preload("res://assets/new_label_settings.tres")
var pixeltextshader = preload("res://shaders/pixeltext.tres")
@onready var playwordbutton = $PlayWord
@onready var chipsandmultcounter = $MultnChipsCounter

var en_dictionary : PackedStringArray

var hand_size : int = 9
var deck = []
var starting_tiles = []
var discarded_tiles = []
var bonus_words = []
var amount_of_bonus_words_to_choose = 5

var typed_word : String
var played_tiles = []
var hand_score : int = 0
var mult: int = 1
var score: int = 0

var playing_hand: bool = false

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
			starting_tiles.append(1)
			starting_tiles.append(9)
		if i <= 2:
			starting_tiles.append(2)
			starting_tiles.append(3)
			starting_tiles.append(6)
			starting_tiles.append(8)
			starting_tiles.append(13)
			starting_tiles.append(16)
			starting_tiles.append(22)
			starting_tiles.append(23)
			starting_tiles.append(25)
		if i <= 4:
			starting_tiles.append(4)
			starting_tiles.append(12)
			starting_tiles.append(19)
			starting_tiles.append(21)
		starting_tiles.append(5)
		if i <= 3:
			starting_tiles.append(7)
		if i == 1:
			starting_tiles.append(10)
			starting_tiles.append(11)
			starting_tiles.append(17)
			starting_tiles.append(24)
			starting_tiles.append(26)
		if i <= 6:
			starting_tiles.append(14)
			starting_tiles.append(18)
			starting_tiles.append(20)
		if i <= 8:
			starting_tiles.append(15)
	for i in len(starting_tiles):
		var tile_instance = tile_scene.instantiate()
		#hand.add_child(tile_instance)
		#tile_instance.change_letter(Letters.NUM_TO_LETTER[starting_tiles[i]])
		tile_instance.letter = starting_tiles[i]
		tile_instance.number = Letters.LETTER_VALUES[Letters.NUM_TO_LETTER[tile_instance.letter]]
		tile_instance.name = Letters.NUM_TO_LETTER[tile_instance.letter]
		tile_instance.get_node("Letter").frame = tile_instance.letter
		tile_instance.get_node("Number").text = str(tile_instance.number)
		tile_instance.tooltip_text = "\"" + Letters.NUM_TO_LETTER[tile_instance.letter] + "\"\n" + str(tile_instance.number) + " Point" + ("s" if tile_instance.number != 1 else "")
		tile_instance.tile_clicked.connect(_on_tile_clicked)
		deck.append(tile_instance)
	deck.shuffle()
	
	draw_tiles_from_deck(true)
	#for i in hand_size:
		#var chosen_letter = deck.pick_random()
		#deck.remove_at(deck.find(chosen_letter))
		#draw_new_tile(Letters.NUM_TO_LETTER[chosen_letter])
		#await get_tree().create_timer(0.14).timeout
	#print(deck)
	new_bonus_words(amount_of_bonus_words_to_choose)

func _process(_delta) -> void:
	handCounter.text = str(hand.get_child_count()) + "/" + str(hand_size)
	chipsandmultcounter.text = ("Multiplier: " + (str(len(played_tiles)) if playing_hand == false else (str(len(played_tiles) + 10) if bonus_words.has(typed_word.to_lower()) else str(mult))) + "\nPoints: " + str(hand_score))

func draw_new_tile(letter = "") -> void:
	var tile_instance = tile_scene.instantiate()
	hand.add_child(tile_instance)
	tile_instance.tile_clicked.connect(_on_tile_clicked)
	if letter != "":
		tile_instance.change_letter(letter)
	sort_hand()
	
func draw_tiles_from_deck(fill_hand: bool = false, count: int = 1, delay: float = 0.14) -> void:
	for i in (hand_size - hand.get_child_count()) if fill_hand else count:
		#var tile_instance = tile_scene.instantiate()
		var chosen_tile = deck.pick_random()
		deck.remove_at(deck.find(chosen_tile))
		hand.add_child(chosen_tile)
		#tile_instance.tile_clicked.connect(_on_tile_clicked)
		#tile_instance.change_letter(Letters.NUM_TO_LETTER[chosen_letter])
		sort_hand()
		if count > 1 or fill_hand:
			await get_tree().create_timer(delay).timeout

func sort_hand() -> void:
	var tiles_to_be_sorted = hand.get_children()
	tiles_to_be_sorted.sort_custom(func(a, b): return a.name.naturalnocasecmp_to(b.name) < 0)
	for i in len(tiles_to_be_sorted):
		hand.move_child(tiles_to_be_sorted[i], i)

func new_bonus_words(amount) -> void:
	bonus_words = []
	for i in bonuswordscontainer.get_child_count():
		if i >= 1:
			bonuswordscontainer.get_children()[i].queue_free()
	for i in amount:
		var new_bonus_word_text_label = Label.new()
		var chosen_bonus_word = en_dictionary[randi_range(0, len(en_dictionary))]
		while len(chosen_bonus_word) < 4 or len(chosen_bonus_word) > 6:
			chosen_bonus_word = en_dictionary[randi_range(0, len(en_dictionary))]
			#print("attempting to choose bonus word " + chosen_bonus_word)
		bonus_words.append(chosen_bonus_word)
		new_bonus_word_text_label.text = bonus_words[-1]
		new_bonus_word_text_label.label_settings = bonuswordlabelsettings
		new_bonus_word_text_label.material = pixeltextshader
		new_bonus_word_text_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		bonuswordscontainer.add_child(new_bonus_word_text_label)
	print(bonus_words)

func _on_tile_clicked(clicked_tile) -> void:
	if clicked_tile.get_parent() == hand:
		typed_word += Letters.NUM_TO_LETTER[clicked_tile.letter]
		word_display.text = typed_word + "\n" + str(in_dictionary(typed_word))
		print(typed_word + "\n" + str(in_dictionary(typed_word)))
		played_tiles.append(clicked_tile)
		hand.remove_child(clicked_tile)
		tile_playmat.add_child(clicked_tile)
	elif clicked_tile.get_parent() == tile_playmat and playing_hand == false:
		played_tiles.remove_at(clicked_tile.get_index())
		typed_word = typed_word.erase(clicked_tile.get_index())
		word_display.text = word_display.text.erase(clicked_tile.get_index())
		tile_playmat.remove_child(clicked_tile)
		hand.add_child(clicked_tile)
		sort_hand()
	if in_dictionary(typed_word):
		playwordbutton.disabled = false
	else:
		playwordbutton.disabled = true

func _on_word_cleared() -> void:
	for i in len(played_tiles):
		tile_playmat.remove_child(played_tiles[i])
		hand.add_child(played_tiles[i])
	sort_hand()
	played_tiles = []
	typed_word = ""
	word_display.text = ""

func _on_word_played() -> void:
	if in_dictionary(typed_word):
		typed_word = typed_word.to_lower()
		playing_hand = true
		hand_score = 0
		mult = len(played_tiles)
		#await get_tree().create_timer(0.3).timeout
		if bonus_words.has(typed_word):
			print("played bonus word " + typed_word)
			mult += 10
		for i in len(played_tiles):
			hand_score += played_tiles[i].number
			soundplayer.play()
			await get_tree().create_timer(0.3).timeout
		hand_score *= mult
		score += hand_score
		scoreCounter.text = "Score: " + str(score)
		print(hand_score)
		played_tiles = []
		for i in tile_playmat.get_children():
			tile_playmat.remove_child(tile_playmat.get_children()[0])
		typed_word = ""
		word_display.text = ""
		draw_tiles_from_deck(true)
		hand_score = 0
		playing_hand = false

func _on_tiles_discarded() -> void:
	discarded_tiles += played_tiles
	played_tiles = []
	for i in tile_playmat.get_children():
		tile_playmat.remove_child(tile_playmat.get_children()[0])
	typed_word = ""
	word_display.text = ""
	sort_hand()
	draw_tiles_from_deck(true)
