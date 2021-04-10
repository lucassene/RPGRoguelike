extends KinematicBody2D
class_name Actor

signal destination_reached

const PROXIMITY_THRESHOLD = 3.0
export(float) var SPEED = 3.0

var speed_track = []
var current_target = Vector2.ZERO

func move_to(target):
	current_target = target

func spawn(spawn_position):
	global_position = spawn_position

func _physics_process(delta):
	_move(delta)

func _move(delta):
	if current_target != Vector2.ZERO:
		global_position = global_position.linear_interpolate(current_target,delta*SPEED)
		if _has_arrived():
			current_target = Vector2.ZERO
			emit_signal("destination_reached")

func _has_arrived():
	if global_position.distance_to(current_target) < PROXIMITY_THRESHOLD:
		global_position = current_target
		return true
	return false
