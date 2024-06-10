extends PopupDialog

signal auth_completed

const MAX_LENGHT := 15
const MIN_LENGHT := 3

const ERROR_MAX_LENGTH := "Username should have at most 15 characters!"
const ERROR_MIN_LENGTH := "Username should have at lest 3 characters!"

onready var _line_edit: LineEdit = $CenterContainer/VBoxContainer/HBoxContainer/LineEdit
onready var _error_label: Label = $CenterContainer/VBoxContainer/ErrorLabel
onready var _button: Button = $CenterContainer/VBoxContainer/Button
onready var _connecting_label: Label = $CenterContainer/VBoxContainer/ConnectingLabel

var _username: String = ""


# Updates internal username value with every change on input.
# Also removes validation warning if all is ok.
func _on_LineEdit_text_changed(new_text: String) -> void:
	_username = new_text
	if _is_username_valid():
		_error_label.visible = false
		_button.disabled = false


# Checks if username is valid and triggers button press
func _on_LineEdit_text_entered(new_text):
	if not _is_username_valid():
		_show_error()
		_button.disabled = true
		return
	
	_on_Button_pressed()


# Checks if current username value is valid
func _is_username_valid() -> bool:
	return _username.length() <= MAX_LENGHT and _username.length() >= MIN_LENGHT


# Callback for button pressed. Also shows error when username is not valid.
# Triggers authentication if all is ok.
func _on_Button_pressed() -> void:
	if not _is_username_valid():
		_show_error()
		_button.disabled = true
		return
	
	_connecting_label.visible = true
	_button.visible = false
	
	var res: int = yield(ConnectionManager.authenticate(_username), "completed")
	if res == 0:
		emit_signal("auth_completed")


# Shows apropriate error message
func _show_error() -> void:
	if _username.length() > MAX_LENGHT:
		_error_label.text = ERROR_MAX_LENGTH
	else:
		_error_label.text = ERROR_MIN_LENGTH
	_error_label.visible = true


# Hides error message
func _hide_error() -> void:
	_error_label.visible = false


func reset() -> void:
	_button.disabled = false
	_button.visible = true
	_hide_error()
	_connecting_label.visible = false
