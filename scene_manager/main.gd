extends Node

var INFORMATION_HEADER_SCENE: PackedScene = preload("res://ui/information_header/information_header.tscn")
var FOREST_ARENA_SCENE: PackedScene = preload("res://arenas/forest.tscn")

onready var _canvas_layer: CanvasLayer = $CanvasLayer
onready var _session_window: Popup = $CanvasLayer/SessionWindow

var _information_header: InformationHeader = null
var _curr_arena: Node2D = null


func _ready():
	_session_window.popup_centered_minsize()


func _on_SessionWindow_auth_completed():
	_create_information_header()
	ConnectionManager.assign_match()
	yield(ConnectionManager, "matched")
	print("Match created!")
	_session_window.hide()
	_canvas_layer.add_child(_information_header)
	_start_game()


func _create_information_header() -> void:
	_information_header = INFORMATION_HEADER_SCENE.instance()
	_information_header.connect("timer_completed", self, "_on_timer_completed")


func _on_timer_completed() -> void:
	print("Match is over!")


func _start_game() -> void:
	_curr_arena = FOREST_ARENA_SCENE.instance()
	add_child(_curr_arena)
