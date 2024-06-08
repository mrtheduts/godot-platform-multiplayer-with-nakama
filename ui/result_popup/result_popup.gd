extends ConfirmationDialog

signal restarted_game


func _ready():
	popup_exclusive = true
	get_close_button().visible = false
	get_close_button().connect("pressed", self, "_on_exit_button")
	get_cancel().text = "Exit"
	get_ok().text = "Play again!"
	popup_centered()


func show_win() -> void:
	dialog_text = "You Won!"
	popup_centered()


func show_lose() -> void:
	dialog_text = "You Lost!"
	popup_centered()


func _on_ConfirmationDialog_confirmed():
	emit_signal("restarted_game")


func _on_exit_button() -> void:
	print("Quitting!")
	get_tree().quit(0)
