extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func spawn_player() -> void:
	var spots: Array = get_children()
	if spots.size() > 0:
		spots.shuffle()
		var position = spots.pop_front().position
		var new_player := Player.new()
		new_player.position = position
		
		
