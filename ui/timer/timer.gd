extends Label

class_name MyTimer

signal completed

const TOTAL_TIME := 60 # seconds

var curr_time := 0


func _ready():
	start()
	_update()

func start() -> void:
	curr_time = TOTAL_TIME
	var tween := get_tree().create_tween()
	tween.tween_interval(1.0)
	tween.tween_callback(self, "decrease_timer")


func decrease_timer() -> void:
	curr_time -= 1
	_update()
	
	if curr_time != 0:
		var tween := get_tree().create_tween()
		tween.tween_interval(1.0)
		tween.tween_callback(self, "decrease_timer")
	else:
		emit_signal("completed")


func _update() -> void:
	text = String(curr_time)
