extends KinematicBody2D

class_name Player

const GRAVITY := 1200
const WALK_VELOCITY := 500
const JUMP_VELOCITY := 600

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
	
	_velocity = move_and_slide(_velocity, Vector2.UP)
	if abs(_velocity.x) > 0 or abs(_velocity.y) > 0:
		_on_mouse_pos_updated(get_global_mouse_position())
	
	if not is_on_floor():
		_velocity.y += delta * GRAVITY
	elif is_on_floor() and _input_map["jump"]:
		_velocity.y = -JUMP_VELOCITY
		_is_jumping = true
	else:
		_velocity.y = 0
		_is_jumping = false


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
		_on_mouse_pos_updated(get_global_mouse_position())

func _on_mouse_pos_updated(new_global_pos: Vector2) -> void:
	var dir_to := position.direction_to(new_global_pos)
	var hand_pos: Vector2 = dir_to * 70
	$Hand.position = hand_pos
	
	var offset_angle = 39
	if hand_pos.x < 0:
		$Hand.scale.x = -1
		offset_angle = 180 - 39
	else:
		$Hand.scale.x = 1
	
	var hand_angle = dir_to.angle() + deg2rad(offset_angle)
	$Hand.rotation = hand_angle
	
	
