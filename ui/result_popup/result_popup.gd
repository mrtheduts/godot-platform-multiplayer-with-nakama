extends ConfirmationDialog

class_name ResultPopup

signal restarted_game


# Called when the node enters the scene tree for the first time.
func _ready():
	popup_exclusive = true
	get_close_button().visible = false
	get_cancel().connect("pressed", self, "_on_exit_button")
	get_cancel().text = "Exit"
	get_ok().text = "Play again!"


# Popups with win message
func show_win() -> void:
	dialog_text = "You Won!"
	popup_centered()


# Popups with lose message
func show_lose() -> void:
	dialog_text = "You Lost!"
	popup_centered()


# Popups with tie message
func show_tie() -> void:
	dialog_text = "You tied!"
	popup_centered()


# Callback for button pressing. Restarts game.
func _on_ConfirmationDialog_confirmed():
	emit_signal("restarted_game")


# Exits game
func _on_exit_button() -> void:
	get_tree().quit(0)
