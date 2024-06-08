extends HBoxContainer

class_name InformationHeader

signal timer_completed

onready var _score: Score = $Score
onready var _score_enemy: Score = $ScoreEnemy


func increase_score() -> void:
	_score.increase()


func increase_score_enemy() -> void:
	_score_enemy.increase()


func _on_Timer_completed():
	emit_signal("timer_completed")


# Returns the result of the match:
# < 0: Lost
# 0: Tie
# > 0: Won
func has_player_won() -> int:
	return _score.score - _score_enemy.score
