extends KinematicBody2D

class_name Player

signal died

onready var RED_BODY: Texture = load("res://player/shapes/red_body_square.png")
onready var RED_HAND: Texture = load("res://player/shapes/red_hand_point.png")

onready var BULLET_TEXTURE: Texture = load("res://player/particles/trace_01.png")

onready var FACE_TEXTURES: Dictionary = {
	"normal": load("res://player/faces/face_a.png"),
	"jumping": load("res://player/faces/face_d.png"),
	"shooting": load("res://player/faces/face_g.png"),
	"happy_angry": load("res://player/faces/face_f.png"),
	"dead": load("res://player/faces/face_j.png"),
}

onready var MUZZLE_TEXTURES: Array = [
	load("res://player/particles/muzzle_01.png"),
	load("res://player/particles/muzzle_02.png"),
	load("res://player/particles/muzzle_03.png"),
	load("res://player/particles/muzzle_04.png"),
	load("res://player/particles/muzzle_05.png"),
]

const GRAVITY := 1200
const WALK_VELOCITY := 500
const JUMP_VELOCITY := 600

const BULLET_VELOCITY := 8000
const SHOT_DURATION := 0.10 # seconds
const SHOT_COOLDOWN := 0.25 # seconds

export var is_local_player := false

var _input_map: Dictionary = {
	"move_left": false,
	"move_right": false,
	"jump": false,
	"fall": false,
	"shoot": false
}

var _velocity: Vector2 = Vector2.ZERO
var _is_jumping := false
var _is_falling := false

var _current_target_pos: Vector2

var _is_shooting := false
var _shot_time := 0.0

var _shot_cooldown_time := 0.0
var _is_on_shot_cooldown := false

const UPDATE_POS_TIME := 0.20
var _update_pos_counter := 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize() # Init RNG for muzzle randomization
	if not is_local_player:
		$Body.texture = RED_BODY
		$Hand.texture = RED_HAND


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# If player is not shooting or is on cooldown, it is able to input a shot
	if _input_map["shoot"] and not _is_shooting and not _is_on_shot_cooldown and is_local_player:
		rpc("_start_shooting")
	
	# The shot will last a while to enable collision detection.
	# If duration ends, it enters cooldown time
	if _shot_time >= SHOT_DURATION and is_local_player:
		rpc("_stop_shooting")
		_is_on_shot_cooldown = true
	elif _is_shooting:
		_shot_time += delta
	
	# Increases cooldown time, and resets after it ends
	if _is_on_shot_cooldown:
		_shot_cooldown_time += delta
		if _shot_cooldown_time >= SHOT_COOLDOWN:
			_shot_cooldown_time = 0.0
			_is_on_shot_cooldown = false


# Called every physics frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	# While shot lasts, it detects if enemy is hit
	if _is_shooting:
		_detect_target_hit()
	
	# Horizontal Movement
	_velocity.x = 0
	if _input_map["move_left"]:
		_velocity.x -= WALK_VELOCITY
	if _input_map["move_right"]:
		_velocity.x += WALK_VELOCITY
	
	# Removes platform collision for falling
	if _input_map["fall"]:
		collision_mask = 0b100
	else:
		collision_mask = 0b101
	
	# Player movement, also updates aim position
	_velocity = move_and_slide(_velocity, Vector2.UP)
	if abs(_velocity.x) > 0 or abs(_velocity.y) > 0:
		_on_mouse_pos_updated(get_global_mouse_position())
	
	# Vertical Movement
	# If it is not on floor, it's falling
	if not is_on_floor():
		_velocity.y += delta * GRAVITY
	# If it is on floor, is able to jump
	elif is_on_floor() and _input_map["jump"]:
		_change_face_to("jumping")
		_velocity.y = -JUMP_VELOCITY
		_is_jumping = true
	# Otherwise, it stays on ground
	else:
		if _is_jumping:
			_change_face_to("normal")
		_velocity.y = 0
		_is_jumping = false
	
	# Update remote position for correction
	if is_local_player:
		_update_pos_counter += delta
		if _update_pos_counter >= UPDATE_POS_TIME:
			_update_pos_counter = 0.0
			rpc_unreliable("update_remote_position", position)


# Checks if remote connection has to be corrected
remote func update_remote_position(pos: Vector2) -> void:
	if abs(position.x - pos.x) >= 50 or abs(position.y - pos.y) >= 50:
		position = pos


# Creates shooting visual effects and starts raycast detection
remotesync func _start_shooting() -> void:
	_is_shooting = true
	$Hand/RayCast2D.enabled = true
	_shot_time = 0.0
	
	# Randomize muzzle light texture
	var index = rand_range(1, 5) as int
	$Hand/Light2D.texture = MUZZLE_TEXTURES[index]
	$Hand/Light2D.enabled = true
	
	var bullet := Sprite.new()
	bullet.texture = BULLET_TEXTURE
	bullet.scale = Vector2(0.5, 0.5)
	bullet.modulate.a = 0.5
	
	var offset_angle = 48 # fixed starting rotation in degrees
	var is_hand_mirrored := false
	# If target is on left side, the offset angle will be rotated 180
	if $Hand.scale.x == -1:
		offset_angle = 180 - offset_angle
		is_hand_mirrored = true
	
	bullet.rotation = $Hand.rotation + deg2rad(offset_angle)
	get_parent().add_child(bullet)
	bullet.position = position + $Hand.position
	
	var bullet_dir := Vector2.UP * BULLET_VELOCITY
	if is_hand_mirrored:
		bullet_dir = bullet_dir.rotated(bullet.rotation + deg2rad(180))
	else:
		bullet_dir = bullet_dir.rotated(bullet.rotation)
	
	# Bullet movement for the duration of the shot
	var tween := get_tree().create_tween()
	tween.tween_property(
		bullet,
		"position", 
		bullet.position + (bullet_dir  * SHOT_DURATION),
		SHOT_DURATION
	)
	tween.tween_callback(self, "_free_bullet", [bullet])


# Detects if raycast shot has hit an enemy
func _detect_target_hit() -> void:
	$Hand/RayCast2D.force_raycast_update()
	# Shot has hit
	if $Hand/RayCast2D.is_colliding():
		var target = $Hand/RayCast2D.get_collider() as Player
		if target != null:
			target.get_hit()
			_change_face_to("happy_angry")
	# Hit missed
	else:
		_change_face_to("shooting")
	
	# Timer to change face back to normal
	var tween := get_tree().create_tween()
	tween.tween_interval(1.0)
	tween.tween_callback(self, "_change_face_to", ["normal"])
	


# Dies on hit.
# Called by enemy object
func get_hit() -> void:
	$Body/Face.texture = FACE_TEXTURES["dead"]
	$Body/HitParticle.emitting = true
	# Dying fade out
	var tween := get_tree().create_tween()
	tween.tween_property(self, "modulate", Color.transparent, 0.5)
	tween.tween_callback(self, "_die")


# Changes face to given sprite
func _change_face_to(name: String) -> void:
	$Body/Face.texture = FACE_TEXTURES[name]


# Removes player object
func _die() -> void:
	emit_signal("died", self, name, is_local_player)


# Removes bullet.
# Is a callback of when bullet movement ends
func _free_bullet(bullet: Node2D) -> void:
	if bullet != null:
		bullet.queue_free()


# Finishes shooting detection and effects
remotesync func _stop_shooting() -> void:
	_is_shooting = false
	$Hand/RayCast2D.enabled = false
	$Hand/Light2D.enabled = false


# Input listener
func _unhandled_input(event):
	if not is_local_player:
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
		rpc("update_remote_input", _input_map)
	if event is InputEventMouseButton:
		_input_map["shoot"] = event.pressed
	if event is InputEventMouseMotion:
		_on_mouse_pos_updated(get_global_mouse_position())
	


remote func update_remote_input(input_map: Dictionary) -> void:
	_input_map = input_map


# Updates target to match mouse's position.
# Its movement is frozen during shots.
func _on_mouse_pos_updated(new_global_pos: Vector2) -> void:
	if not is_local_player or _is_shooting:
		return
	
	var dir_to := position.direction_to(new_global_pos + Vector2(42, 42)) # Custom target cursor offset
	var hand_pos: Vector2 = dir_to * 70 # distance from center
	rpc_unreliable("update_hand_pos", hand_pos)
	
	var offset_angle = 39 # fixed starting rotation in degrees
	if hand_pos.x < 0:
		# If target is on left side, the offset angle will be rotated 180
		offset_angle = 180 - 39
		$Hand.scale.x = -1
	else:
		$Hand.scale.x = 1
	
	var hand_angle = dir_to.angle() + deg2rad(offset_angle)
	
	$Hand.rotation = hand_angle
	rpc_unreliable("update_hand_rot", hand_angle, hand_pos.x < 0)

remotesync func update_hand_pos(pos: Vector2) -> void:
	$Hand.position = pos

remote func update_hand_rot(rot: float, should_add_mirror: bool) -> void:
	$Hand.rotation = rot
	if should_add_mirror:
		$Hand.scale.x = -1
	else:
		$Hand.scale.x = 1
