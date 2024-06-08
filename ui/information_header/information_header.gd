extends HBoxContainer

class_name InformationHeader

signal timer_completed

onready var _score: Score = $Score
onready var _score_enemy: Score = $ScoreEnemy

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func increase_score_enemy() -> void:
	_score_enemy.increase()


func increase_score() -> void:
	_score.increase()


func _on_Timer_completed():
	emit_signal("timer_completed")
