extends Node2D

var PLAYER_SCENE = load("res://player/player.tscn")

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func spawn_player(is_player: bool = false) -> void:
	var spots: Array = get_children()
	if spots.size() > 0:
		spots.shuffle()
		var position = spots.pop_front().position
		var new_player: Player = PLAYER_SCENE.instance()
		new_player.is_player = is_player
		new_player.connect("died", self, "spawn_player")
		get_parent().add_child(new_player)
		new_player.position = position
