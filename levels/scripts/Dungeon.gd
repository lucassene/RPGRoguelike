extends Node2D

onready var cells_db = preload("res://helpers/scripts/CellsDB.gd").new()
onready var cell_container = $CellContainer
onready var hud = $CanvasLayer/HUD
onready var tween: Tween = $Tween
onready var player: Actor = $Players/Player

var current_cell
var new_cell

func _ready():
	cells_db.initialize()
	current_cell = _generate_new_cell()
	_update_hud()

func _generate_new_cell():
	var cell = cells_db.get_random_cell()
	cell = load(cell).instance()
	cell_container.add_child(cell)
	cell_container.move_child(cell,0)
	return cell

func _update_hud():
	hud.set_exits(current_cell.get_exits())

func _fade_cell():
	tween.interpolate_property(current_cell,"modulate:a",1.0,0.0,0.5,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
	tween.start()

func _on_HUD_direction_pressed(direction):
	var target = current_cell.get_exit_position(direction)
	if target != null:
		var path = current_cell.get_actor_path(player,target)
		player.move_to(path)
	new_cell = _generate_new_cell()
	_fade_cell()

func _on_Tween_tween_completed(_object, _key):
	current_cell.queue_free()
	current_cell = new_cell
	new_cell = null
	_update_hud()
