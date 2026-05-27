extends TextureButton

@onready var soundplayer = $AudioStreamPlayer
const BUTTON_DOWN_SOUND = preload("res://sounds/buttonDown.ogg")
const BUTTON_UP_SOUND = preload("res://sounds/buttonUp.ogg")

func _on_button_down() -> void:
	soundplayer.stream = BUTTON_DOWN_SOUND
	soundplayer.play()


func _on_button_up() -> void:
	soundplayer.stream = BUTTON_UP_SOUND
	soundplayer.play()
