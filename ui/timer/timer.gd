extends Label

class_name MyTimer

signal completed

const TOTAL_TIME := 60 # seconds

var curr_time := 0

var tween: SceneTreeTween = null


# Called when the node enters the scene tree for the first time.
func _ready():
	start()
	_update()


# Starts timer
func start() -> void:
	curr_time = TOTAL_TIME
	tween = get_tree().create_tween()
	tween.tween_interval(1.0)
	tween.tween_callback(self, "decrease_timer")


# Decreases total timer's time
func decrease_timer() -> void:
	curr_time -= 1
	_update()
	
	if curr_time != 0:
		tween = get_tree().create_tween()
		tween.tween_interval(1.0)
		tween.tween_callback(self, "decrease_timer")
	else:
		emit_signal("completed")


# Updates timer's label
func _update() -> void:
	text = String(curr_time)


# Stops time countdown
func stop_timer() -> void:
	tween.stop()
	tween = null
