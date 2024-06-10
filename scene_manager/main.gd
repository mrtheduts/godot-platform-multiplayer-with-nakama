extends Node

var CUSTOM_CURSOR_NORMAL = preload("res://cursors/hand_point.png")
var CUSTOM_CURSOR_TARGET = preload("res://cursors/target.png")

var INFORMATION_HEADER_SCENE: PackedScene = preload("res://ui/information_header/information_header.tscn")
var FOREST_ARENA_SCENE: PackedScene = preload("res://arenas/forest.tscn")

onready var _canvas_layer: CanvasLayer = $CanvasLayer
onready var _session_window: Popup = $CanvasLayer/SessionWindow
onready var _result_popup: ResultPopup = $CanvasLayer/ResultPopup

var _information_header: InformationHeader = null
var _curr_arena: Node2D = null
var _local_player: Player = null

var _curr_players: Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	ConnectionManager.connect("player_left", self, "_on_player_left")
	ConnectionManager.connect("matched", self, "_on_connection_matched")
	ConnectionManager.connect("player_joined", self, "_on_player_joined")
	_start_user_info_input()


# Pops up window for username input and connection button
func _start_user_info_input() -> void:
	Input.set_custom_mouse_cursor(CUSTOM_CURSOR_NORMAL)
	_session_window.popup_centered_minsize()


# Callback for SessionWindow authentication
func _on_SessionWindow_auth_completed():
	_create_information_header()
	ConnectionManager.assign_match()


func _on_connection_matched(player_id: int) -> void:
	_session_window.hide()
	_canvas_layer.add_child(_information_header)
	_setup_game()
	_local_player = _spawn_player(str(player_id), true)
	
	get_tree().set_pause(true)


func _on_player_joined(player: ConnectionManager.ConnectionPlayer) -> void:
	var peer_id := player.peer_id
	var my_peer_id := get_tree().get_network_unique_id()
	
	rpc_id(peer_id, "_spawn_player", str(my_peer_id), false, _local_player.position)


remotesync func _game_start() -> void:
	get_tree().set_pause(false)


# Creates UI for scores and timer
func _create_information_header() -> void:
	_information_header = INFORMATION_HEADER_SCENE.instance()
	_information_header.connect("timer_completed", self, "_on_timer_completed")


# Destroys UI for scores and timer
func _remove_information_header() -> void:
	if _information_header != null:
		_information_header.queue_free()
		_information_header = null


# Creates an arena and adds to scene
func _setup_game() -> void:
	Input.set_custom_mouse_cursor(CUSTOM_CURSOR_TARGET)
	_curr_arena = FOREST_ARENA_SCENE.instance()
	add_child(_curr_arena)


func _respawn_player(dead_player: Player, player_id: String, is_local_player: bool) -> void:
	_curr_players.erase(is_local_player)
	dead_player.name = "dead"
	dead_player.queue_free()
	if not is_local_player:
		return
	
	var player := _spawn_player(player_id, is_local_player)
	if is_local_player:
		rpc("_spawn_player", player_id, false, player.position)

# Spawns player at random positions
remote func _spawn_player(player_id: String, is_local_player: bool, init_pos: Vector2 = Vector2.ZERO) -> Player:
	if _curr_players.has(is_local_player):
		return _curr_players[is_local_player]
	
	var spawner: SpawnPoints = _curr_arena.get_node("SpawnPoints")
	var player = spawner.spawn_player(player_id, is_local_player)
	player.connect("died", self, "_respawn_player")
	player.connect("died", self, "_increase_score")
	
	if not is_local_player:
		player.position = init_pos
		rpc('_game_start')
	
	_curr_players[is_local_player] = player
	return player


# Increases score
func _increase_score(_dead_player, _name, is_local_player: bool) -> void:
	if not is_local_player:
		_information_header.increase_score()
	else:
		_information_header.increase_score_enemy()


# Removes the current arena
func _stop_game() -> void:
	if _curr_arena != null:
		_curr_arena.queue_free()
		_curr_arena = null


func _on_player_left() -> void:
	_information_header.stop_timer()
	_on_timer_completed(true)

# Shows result popup.
# Callback on match timer completed.
func _on_timer_completed(player_left: bool = false) -> void:
	Input.set_custom_mouse_cursor(CUSTOM_CURSOR_NORMAL)
	var tween := get_tree().create_tween()
	tween.tween_property(_curr_arena, "modulate", Color.transparent, 0.5)
	tween.tween_callback(self, "_stop_game")
	
	if player_left:
		_result_popup.show_win()
		return
	
	var result := _information_header.has_player_won()
	if result < 0:
		_result_popup.show_lose()
	elif result == 0:
		_result_popup.show_tie()
	else:
		_result_popup.show_win()


# Restarts game.
# Callback on ResultPopup confirmation
func _on_ResultPopup_restarted_game():
	_reset_everything()
	_start_user_info_input()

func _reset_everything() -> void:
	ConnectionManager.end_connection()
	_remove_information_header()
	_session_window.reset()
	_curr_players.clear()
