extends Node


onready var _session_window: Popup = $CanvasLayer/SessionWindow

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	_session_window.popup_centered_minsize()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_SessionWindow_auth_completed():
	ConnectionManager.create_match()
