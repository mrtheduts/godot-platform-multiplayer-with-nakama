extends Node2D

class_name SpawnPoints

var PLAYER_SCENE = load("res://player/player.tscn")

# Spawns player at random point, which are the location of its children
# @ is_player: true if this player should listen to the user inputs
func spawn_player(is_local_player: bool = false) -> Player:
	var spots: Array = get_children()
	
	# Spawner has no children to serve as position sources
	if spots.size() == 0:
		return null

	spots.shuffle()
	var position = spots.pop_front().position
	
	var new_player: Player = PLAYER_SCENE.instance()
	new_player.is_local_player = is_local_player
	
	get_parent().add_child(new_player)
	new_player.position = position
	return new_player
