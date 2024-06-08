extends Label

class_name Score

var _score := 0


func _ready():
	_update()


func increase() -> void:
	_score += 1
	_update()

func reset() -> void:
	_score = 0
	_update()

func _update() -> void:
	text = String(_score)
