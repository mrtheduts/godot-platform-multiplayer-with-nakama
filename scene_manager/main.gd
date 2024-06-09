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

# Called when the node enters the scene tree for the first time.
func _ready():
	_start_user_info_input()


# Pops up window for username input and connection button
func _start_user_info_input() -> void:
	Input.set_custom_mouse_cursor(CUSTOM_CURSOR_NORMAL)
	_session_window.popup_centered_minsize()


# Callback for SessionWindow authentication
func _on_SessionWindow_auth_completed():
	_create_information_header()
	ConnectionManager.assign_match()
	
	# Waits for matchmaking success
	yield(ConnectionManager, "matched")
	
	_session_window.hide()
	_canvas_layer.add_child(_information_header)
	_start_game()


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
func _start_game() -> void:
	Input.set_custom_mouse_cursor(CUSTOM_CURSOR_TARGET)
	_stop_game()
	_curr_arena = FOREST_ARENA_SCENE.instance()
	add_child(_curr_arena)


# Removes the current arena
func _stop_game() -> void:
	if _curr_arena != null:
		_curr_arena.queue_free()
		_curr_arena = null


# Shows result popup.
# Callback on match timer completed.
func _on_timer_completed() -> void:
	Input.set_custom_mouse_cursor(CUSTOM_CURSOR_NORMAL)
	var tween := get_tree().create_tween()
	tween.tween_property(_curr_arena, "modulate", Color.transparent, 0.5)
	tween.tween_callback(self, "_stop_game")
	
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
	_start_game()
