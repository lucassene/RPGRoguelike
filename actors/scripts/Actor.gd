extends KinematicBody2D
class_name Actor

onready var tween: Tween = $Tween
onready var turn_mark: Sprite = $TurnMark

signal destination_reached

const PROXIMITY_THRESHOLD = 3.0
export(float) var SPEED = 3.0
export(GlobalVars.actor_type) var type = GlobalVars.actor_type.PLAYER

var stats = {}
var current_target = Vector2.ZERO
var allowed_movement = PoolVector2Array()
var current_tile = Vector2.ZERO
var parent_cell setget set_parent_cell

func set_parent_cell(value):
	parent_cell = value

func _physics_process(delta):
	_move(delta)

func initialize(_actor,cell):
	parent_cell = cell
	pass

func move_to(tile,target):
	parent_cell.remove_from_taken(current_tile)
	current_tile = tile
	current_target = target

func spawn(spawn_tile,spawn_position):
	current_tile = spawn_tile
	global_position = spawn_position

func begin_turn():
	turn_mark.show()

func end_turn():
	turn_mark.hide()

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
