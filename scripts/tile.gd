extends Control

@onready var tile_number = $Number
@onready var tile_letter = $Letter
#var letterValues = {"A": 1, "B": 3, "C": 3, "D": 2, "E": 1, "F": 4, "G": 2, "H": 4, "I": 1, "J": 8, "K": 5, "L": 1, "M": 3, "N": 1, "O": 1, "P": 3, "Q": 10, "R": 1, "S": 1, "T": 1, "U": 1, "V": 4, "W": 4, "X": 8, "Y": 4, "Z": 10}
#var numToLetter = {1: "A", 2: "B", 3: "C", 4: "D", 5: "E", 6: "F", 7: "G", 8: "H", 9: "I", 10: "J", 11: "K", 12: "L", 13: "M", 14: "N", 15: "O", 16: "P", 17: "Q", 18: "R", 19: "S", 20: "T", 21: "U", 22: "V", 23: "W", 24: "X", 25: "Y", 26: "Z"}
#var letterToNum = {"A": 1, "B": 2, "C": 3, "D": 4, "E": 5, "F": 6, "G": 7, "H": 8, "I": 9, "J": 10, "K": 11, "L": 12, "M": 13, "N": 14, "O": 15, "P": 16, "Q": 17, "R": 18, "S": 19, "T": 20, "U": 21, "V": 22, "W": 23, "X": 24, "Y": 25, "Z": 26}
#var letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

var number: int = 1
var letter: int = 1

@onready var soundplayer = $AudioStreamPlayer

signal tile_clicked(tile)

func _ready() -> void:
	#for i in 26:
		#numToLetter[i + 1] = letters[i]
		#letterToNum[letters[i]] = i + 1
	change_letter(Letters.NUM_TO_LETTER[randi_range(1, 26)])
	soundplayer.pitch_scale = randf_range(0.8, 1.1)
	soundplayer.play()

func change_letter(new_letter: String):
	letter = Letters.LETTER_TO_NUM[new_letter]
	number = Letters.LETTER_VALUES[Letters.NUM_TO_LETTER[letter]]
	name = Letters.NUM_TO_LETTER[letter]
	tile_letter.frame = letter
	tile_number.text = str(number)
	tooltip_text = "\"" + Letters.NUM_TO_LETTER[letter] + "\"\n" + str(number) + " Point" + ("s" if number != 1 else "")

func _on_tile_clicked() -> void:
	print("hello from " + name)
	emit_signal("tile_clicked", self)
