extends Node2D

onready var hero_scene = preload("res://actors/scenes/Hero.tscn")
onready var cell_data = preload("res://database/CellData.gd").new()
onready var hero_data = preload("res://database/HeroData.gd").new()

onready var fade_map = $FadeMap
onready var hud = $CanvasLayer/HUD
onready var tween: Tween = $Tween
onready var heroes_container = $Heroes
onready var cell_container = $CellContainer

var current_cell
var new_cell
var player_party = []
var transition_direction

func _ready():
	DataAccess.load_database()
	_initialize_data()
	current_cell = _generate_new_cell()
	_instance_heroes()
	_update_hud()

func end_battle():
	hud.begin_exploration_mode()

func _initialize_data():
	cell_data.initialize()
	hero_data.initialize()

func _generate_new_cell(cell_type = null):
	DataAccess.open_database()
	if cell_type == null: 
		cell_type = cell_data.get_first_cell_type()
	var cell = cell_data.get_random_cell(cell_type)
	cell = load(cell).instance()
	cell_container.visible = false
	cell_container.add_child(cell)
	cell_container.move_child(cell,0)
	cell_container.visible = true
	cell.initialize(self,cell_data,cell_type)
	return cell

func _update_hud():
	current_cell.initialize_hud()
	hud.initialize(cell_data,current_cell.get_type())
	var types = _get_next_cell_types()
	hud.set_exits(types)
	DataAccess.close_database()

func _get_next_cell_types():
	var selected_types = []
	var next_exits = []
	for exit in current_cell.get_exits():
		var exit_done = false
		while exit_done == false:
			var dict = {
				direction = exit,
				type = cell_data.get_random_cell_type(current_cell.get_type())
			}
			if selected_types.find(dict.type) == -1:
				selected_types.append(dict.type)
				next_exits.append(dict)
				exit_done = true
	return next_exits

func _instance_heroes():
	var heroes_stats = hero_data.get_heroes_in_party()
	for stats in heroes_stats:
		var hero = hero_scene.instance()
		heroes_container.add_child(hero)
		hero.initialize(stats,current_cell)
		hero.connect("destination_reached",self,"_on_player_reached_destination")
		_spawn_hero(hero)
		player_party.append(hero)

func _spawn_hero(hero):
	var spawn_tile = current_cell.get_hero_spawn()
	var spawn_position = current_cell.get_actor_spawn_position(spawn_tile)
	hero.set_parent_cell(current_cell)
	hero.spawn(spawn_tile,spawn_position)
	current_cell.add_hero(hero)

func _spawn_heroes():
	for hero in player_party:
		_spawn_hero(hero)

func _transition_cell():
	_set_new_cell_position()

func _set_new_cell_position():
	var viewport = get_viewport_rect().size
	var cell_size = new_cell.get_cell_size()
	if transition_direction == GlobalVars.direction.NORTH:
		var target = max(cell_size.y,viewport.y)
		new_cell.global_position.y = -target
		_tween_cell(target)
	elif transition_direction == GlobalVars.direction.WEST:
		var target = max(cell_size.x,viewport.x)
		new_cell.global_position.x = -target
		_tween_cell(target)
	else:
		var target = -max(cell_size.x,viewport.x)
		new_cell.global_position.x = -target
		_tween_cell(target)

func _tween_cell(tween_target):
	match transition_direction:
		GlobalVars.direction.NORTH:
			tween.interpolate_property(current_cell,"global_position:y",current_cell.global_position.y,tween_target,1.0,Tween.TRANS_QUINT,Tween.EASE_IN_OUT)
			tween.interpolate_property(new_cell,"global_position:y",new_cell.global_position.y,0.0,1.0,Tween.TRANS_QUINT,Tween.EASE_IN_OUT)
		GlobalVars.direction.WEST,GlobalVars.direction.EAST:
			tween.interpolate_property(current_cell,"global_position:x",current_cell.global_position.x,tween_target,1.0,Tween.TRANS_QUINT,Tween.EASE_IN_OUT)
			tween.interpolate_property(new_cell,"global_position:x",new_cell.global_position.x,0.0,1.0,Tween.TRANS_QUINT,Tween.EASE_IN_OUT)
	tween.start()

func _on_player_reached_destination():
	pass
#	_fade_heroes()
#	yield(get_tree().create_timer(0.5),"timeout")
#	_transition_cell()

func _fade_heroes():
	for hero in player_party:
		hero.fade_out()

func _on_HUD_direction_pressed(direction,cell_type):
	new_cell = _generate_new_cell(cell_type)
	transition_direction = direction
	_fade_heroes()
	yield(get_tree().create_timer(0.5),"timeout")
	_transition_cell()
#	var target = current_cell.get_exit_position(direction)
#	if target != null:
#		player_party[0].move_to(target)

func _on_Tween_tween_completed(object, _key):
	if object == new_cell:
		current_cell.queue_free()
		current_cell = new_cell
		new_cell = null
		_spawn_heroes()
		_update_hud()
