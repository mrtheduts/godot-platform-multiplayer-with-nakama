extends KinematicBody2D

class_name Player

const GRAVITY := 1000

var _velocity: Vector2 = Vector2.ZERO

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
	if not self.is_on_floor():
		_velocity.y += delta * GRAVITY
	else:
		_velocity.y = 0
	
	move_and_slide(_velocity)
	
	
