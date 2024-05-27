extends KinematicBody2D

class_name Player

const GRAVITY := 100
const WALK_VELOCITY := 500
const JUMP_VELOCITY := 500

var _velocity: Vector2 = Vector2.ZERO

var _input_map: Dictionary = {
	"move_left": false,
	"move_right": false,
	"jump": false,
	"fall": false,
	"shoot": false
}

var _current_target_pos: Vector2

var _is_jumping := false

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _physics_process(delta):
	_velocity.x = 0
	if _input_map["move_left"]:
		_velocity.x -= WALK_VELOCITY
	if _input_map["move_right"]:
		_velocity.x += WALK_VELOCITY
	
	_velocity = move_and_slide(_velocity)
	
	if not is_on_floor():
		_velocity.y += delta * GRAVITY
	elif is_on_floor() and _input_map["jump"]:
		_velocity.y = -JUMP_VELOCITY
	else:
		_velocity.y = 0

func _unhandled_input(event):
	if event is InputEventKey:
		if event.scancode == KEY_A or event.scancode == KEY_LEFT:
			_input_map["move_left"] = event.pressed
		elif event.scancode == KEY_D or event.scancode == KEY_RIGHT:
			_input_map["move_right"] = event.pressed
		elif event.scancode == KEY_W or event.scancode == KEY_SPACE:
			_input_map["jump"] = event.pressed
		elif event.scancode == KEY_S:
			_input_map["fall"] = event.pressed
	if event is InputEventMouseButton:
		if event.button_index == 0:
			_input_map["shoot"] = event.pressed
	if event is InputEventMouseMotion:
		_current_target_pos = get_global_mouse_position()
