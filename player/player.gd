extends KinematicBody2D

class_name Player

onready var BULLET_TEXTURE: Texture = load("res://player/particles/trace_01.png")

onready var MUZZLE_TEXTURES: Array = [
	load("res://player/particles/muzzle_01.png"),
	load("res://player/particles/muzzle_02.png"),
	load("res://player/particles/muzzle_03.png"),
	load("res://player/particles/muzzle_04.png"),
	load("res://player/particles/muzzle_05.png")
	
]

const GRAVITY := 1200
const WALK_VELOCITY := 500
const JUMP_VELOCITY := 600
const BULLET_VELOCITY := 8000
const SHOT_DURATION := 0.25

export var is_player := false

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
var _is_shooting := false
var _shot_time := 0.0


# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _physics_process(delta):
	if _input_map["shoot"] and not _is_shooting:
		_start_shooting()
	elif _is_shooting:
		_shot_time += delta
	
	if _shot_time >= SHOT_DURATION:
		_stop_shooting()
		
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


func _start_shooting() -> void:
	_is_shooting = true
	$Hand/RayCast2D.enabled = true
	_shot_time = 0.0
	var index = rand_range(1, 5) as int
	$Hand/Light2D.texture = MUZZLE_TEXTURES[index]
	$Hand/Light2D.enabled = true
	
	var bullet := Sprite.new()
	bullet.texture = BULLET_TEXTURE
	bullet.scale = Vector2(0.5, 0.5)
	
	var offset_angle = 48
	if $Hand.scale.x == -1:
		offset_angle = 180 - offset_angle
	
	bullet.rotation = $Hand.rotation + deg2rad(offset_angle)
	print(bullet.rotation_degrees)
	get_parent().add_child(bullet)
	bullet.position = position + $Hand.position
	
	var tween := get_tree().create_tween()
	tween.tween_property(
		bullet,
		"position", 
		bullet.position + (Vector2.ONE * BULLET_VELOCITY * SHOT_DURATION),
		SHOT_DURATION
	)
	tween.tween_callback(self, "free_bullet", [bullet])


func _free_bullet(bullet: Node2D) -> void:
	if bullet != null:
		bullet.queue_free()


func _stop_shooting() -> void:
	_is_shooting = false
	$Hand/RayCast2D.enabled = false
	$Hand/Light2D.enabled = false
	

func _unhandled_input(event):
	if not is_player:
		return
	
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
		if event.button_index == 1:
			_input_map["shoot"] = event.pressed
	if event is InputEventMouseMotion:
		_on_mouse_pos_updated(get_global_mouse_position())


func _on_mouse_pos_updated(new_global_pos: Vector2) -> void:
	if not is_player:
		return
	
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
	
	
