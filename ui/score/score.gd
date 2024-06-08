extends Label

class_name Score

var score := 0


# Called when the node enters the scene tree for the first time.
func _ready():
	_update()


# Increases score
func increase() -> void:
	score += 1
	_update()


# Updates label text to match current score
func _update() -> void:
	text = String(score)
