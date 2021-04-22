extends Node2D

onready var hero_scene = preload("res://actors/scenes/Hero.tscn")
onready var fade_map = $FadeMap
onready var hud = $CanvasLayer/HUD
onready var tween: Tween = $Tween
onready var heroes_container = $Heroes
onready var cell_container = $CellContainer

var cell_repo
var hero_repo
var skill_repo
var current_cell
var new_cell
var player_party = []
var transition_direction

func _ready():
	_load_repositories()
	_connect_signals()
	current_cell = _generate_new_cell()
	_instance_heroes()
	hud.initialize()
	_update_hud()

func _load_repositories():
	skill_repo = RepoHub.get_skill_repo()
	cell_repo = RepoHub.get_cell_repo()
	hero_repo = RepoHub.get_hero_repo()

func _connect_signals():
	EventHub.connect("hud_direction_pressed",self,"_on_hud_direction_pressed")

func _generate_new_cell(cell_type = null):
	if cell_type == null: 
		cell_type = cell_repo.get_first_cell_type()
	var cell = cell_repo.get_random_cell(cell_type)
	cell = load(cell).instance()
	cell_container.visible = false
	cell_container.add_child(cell)
	cell_container.move_child(cell,0)
	cell_container.visible = true
	cell.initialize(self,cell_type)
	return cell

func _update_hud():
	hud.update_hud(current_cell.get_type())
	var types = _get_next_cell_types()
	hud.set_exits(types)

func _get_next_cell_types():
	var exits = current_cell.get_exits()
	var result = cell_repo.get_next_cells(current_cell.get_type(),exits.size())
	var next_exits = []
	for i in exits.size():
		var dict = {
			direction = exits[i],
			type = result[i]
		}
		next_exits.append(dict)
	return next_exits

func _instance_heroes():
	var heroes = hero_repo.get_heroes_in_party()
	for hero_data in heroes:
		var hero = hero_scene.instance()
		heroes_container.add_child(hero)
		hero.initialize(hero_data,current_cell)
		hero.connect("destination_reached",self,"_on_player_reached_destination")
		_spawn_hero(hero)
		player_party.append(hero)

func _spawn_hero(hero):
	var spawn_tile = current_cell.get_hero_spawn(hero)
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
	if not current_cell.is_in_battle():
		_fade_heroes()
		yield(get_tree().create_timer(0.5),"timeout")
		_transition_cell()

func _fade_heroes():
	for hero in player_party:
		hero.fade_out()

func _on_hud_direction_pressed(direction,cell_type):
	new_cell = _generate_new_cell(cell_type)
	transition_direction = direction
	var targets = current_cell.get_exit_position(direction)
	if targets != null:
		player_party[0].move_to(targets[0],targets[1])

func _on_Tween_tween_completed(object, _key):
	if object == new_cell:
		current_cell.queue_free()
		current_cell = new_cell
		new_cell = null
		_spawn_heroes()
		_update_hud()
