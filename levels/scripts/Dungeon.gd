extends Node2D

onready var player_scene = preload("res://actors/scenes/Player.tscn")

onready var fade_map = $FadeMap
onready var hud = $CanvasLayer/HUD
onready var tween: Tween = $Tween
onready var players_tween: Tween = $Tween
onready var player_container = $Players
onready var cell_container = $CellContainer

enum {IN,OUT}

var current_cell
var new_cell
var player
var current_transition = IN

func _ready():
	randomize()
	current_cell = _generate_new_cell()
	_instance_player()
	_update_hud()

func _generate_new_cell(cell_type = null):
	if cell_type == null:
		cell_type = CellsDb.get_random_cell_type()
	var cell = CellsDb.get_random_cell(cell_type)
	cell = load(cell).instance()
	cell_container.add_child(cell)
	cell_container.move_child(cell,0)
	cell.initialize(cell_type)
	return cell

func _update_hud():
	var exits = []
	var selected_types = []
	for exit in current_cell.get_exits():
		var dict = {
			direction = exit,
			type = CellsDb.get_random_cell_type(selected_types)
		}
		selected_types.append(dict.type)
		exits.append(dict)
	hud.set_exits(exits)

func _fade_cell(type):
	if type == IN:
		tween.interpolate_property(fade_map,"modulate:a",1.0,0.0,1.0,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
		tween.start()
		current_transition = IN
	else:
		tween.interpolate_property(fade_map,"modulate:a",0.0,1.0,0.5,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
		tween.start()
		current_transition = OUT

func _instance_player():
	player = player_scene.instance()
	player_container.add_child(player)
	player.connect("destination_reached",self,"_on_player_reached_destination")
	_spawn_player()

func _spawn_player():
	var spawn_position = current_cell.get_player_spawn()
	player.spawn(spawn_position)

func _on_player_reached_destination():
	yield(get_tree().create_timer(0.5),"timeout")
	_fade_cell(OUT)

func _on_HUD_direction_pressed(direction,cell_type):
	new_cell = _generate_new_cell(cell_type)
	var target = current_cell.get_exit_position(direction)
	if target != null:
		player.move_to(target)

func _on_Tween_tween_completed(_object, _key):
	if current_transition == IN:
		_update_hud()
	else:
		yield(get_tree().create_timer(0.5),"timeout")
		current_cell.queue_free()
		current_cell = new_cell
		new_cell = null
		current_cell.get_player_spawn()
		_spawn_player()
		_fade_cell(IN)

