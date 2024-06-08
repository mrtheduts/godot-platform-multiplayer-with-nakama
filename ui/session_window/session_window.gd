extends PopupDialog

signal auth_completed

const MIN_LENGHT := 10

const ERROR_USERNAME_TAKEN := "Username already taken!"
const ERROR_MIN_LENGHT := "Username should have at least 10 characters!"

onready var _line_edit: LineEdit = $CenterContainer/VBoxContainer/HBoxContainer/LineEdit
onready var _error_label: Label = $CenterContainer/VBoxContainer/ErrorLabel
onready var _button: Button = $CenterContainer/VBoxContainer/Button
onready var _connecting_label: Label = $CenterContainer/VBoxContainer/ConnectingLabel

var _username: String = ""


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_LineEdit_text_changed(new_text: String) -> void:
	_username = new_text
	if _is_username_valid():
		_error_label.visible = false
		_button.disabled = false


func _on_LineEdit_text_entered(new_text):
	if not _is_username_valid():
		_show_error()
		_button.disabled = true
		return
	
	_on_Button_pressed()


func _is_username_valid() -> bool:
	return _username.length() >= MIN_LENGHT


func _on_Button_pressed() -> void:
	if not _is_username_valid():
		_button.disabled = true
	
	_connecting_label.visible = true
	_button.visible = false
	
	var res: int = yield(ConnectionManager.authenticate(_username), "completed")
	print(res)
	if res == 0:
		emit_signal("auth_completed")


func _show_error() -> void:
	_error_label.text = ERROR_MIN_LENGHT
	_error_label.visible = true


func _hide_error() -> void:
	_error_label.visible = false
