extends DungeonCell

onready var effect_methods = preload("res://helpers/scripts/EffectMethods.gd").new()

var current_turn = 0
var current_fighter = 0
var turn_order = []
var can_act = true
var highlighted_tiles = []
var active_skill
var viable_target = []
var tile_left = Vector2.ZERO

func _ready():
	can_act = true
	in_battle = true
	current_turn = 0
	current_fighter = 0
	EventHub.connect("hud_ready",self,"_on_hud_ready")
	EventHub.connect("skill_selected",self,"_on_skill_selected")
	EventHub.connect("skill_canceled",self,"_on_skill_canceled")
	EventHub.connect("skill_executed",self,"_on_skill_executed")
	EventHub.connect("actor_selected",self,"_on_actor_selected")

func _unhandled_input(event):
	if can_act and event.is_action_pressed("next_turn") and current_turn > 0:
		next_turn()
		return
	if can_act and event.is_action_pressed("end_battle") and current_turn > 0:
		_end_battle()
		return
	if event is InputEventScreenTouch and event.is_pressed():
		var tile_touched = world_to_map(event.position)
		if cell_mode == NORMAL:
			if highlighted_tiles.find(tile_touched) != -1:
				_tile_action(tile_touched)
		elif cell_mode == SPACE_SELECTION:
			_on_tile_selected(tile_touched)

func _begin_first_turn():
	turn_order = player_party + enemy_party
	_connect_signals()
	current_turn = 1
	current_fighter = 0
	turn_order[current_fighter].begin_turn()
	EventHub.emit_signal("turn_changed",turn_order[current_fighter].get_actor_name(),false)

func _connect_signals():
	for actor in turn_order:
		actor.connect("destination_reached",self,"_on_actor_reached_destination")
		actor.connect("movement_started",self,"_on_actor_movement_started")
		actor.connect("actor_killed",self,"_on_actor_killed")

func _disconnect_signals():
	for actor in turn_order:
		actor.disconnect("destination_reached",self,"_on_actor_reached_destination")
		actor.disconnect("movement_started",self,"_on_actor_movement_started")
		actor.disconnect("actor_killed",self,"_on_actor_killed")

func _prepare_for_next_turn():
	cell_mode = NORMAL
	_toggle_actor_lights_off()
	overlay_map.show()
	canvas_modulate.hide()

func next_turn():
	_prepare_for_next_turn()
	_change_turn()
	if turn_order.size() > 0:
		turn_order[current_fighter].end_turn()
		current_turn += 1
		current_fighter += 1
		if current_fighter >= turn_order.size():
			current_fighter = 0
		turn_order[current_fighter].begin_turn()
		EventHub.emit_signal("turn_changed",turn_order[current_fighter].get_actor_name(),_is_enemy())
	else:
		_end_battle()

func _is_enemy():
	if enemy_party.find(turn_order[current_fighter]) != -1:
		return true
	return false

func _change_turn():
	_clear_highlighted_tiles()

func _clear_highlighted_tiles():
	for tile in highlighted_tiles:
		overlay_map.set_cell(tile.x,tile.y,-1)

func _tile_action(tile):
	_clear_highlighted_tiles()
	match _get_tile_content(tile):
		EMPTY:
			turn_order[current_fighter].move_to(tile,map_to_world(tile))
			tile_taken.append(tile)

func _end_battle():
	_disconnect_signals()
	if turn_order.size() > 0: turn_order[current_fighter].end_turn()
	_clear_highlighted_tiles()
	current_fighter = 0
	current_turn = 0
	turn_order.clear()
	in_battle = false
	EventHub.emit_signal("battle_ended")

func calculate_movement(_tile,hero):
	var movement = []
	var to_check = [{tile = _tile,value = 0}]
	var checked_tiles = []
	for t in to_check:
		if checked_tiles.find(t.tile) == -1:
			for n in _get_neighbors(t.tile):
				var nt ={tile = n,value = t.value + 1}
				if _can_move(n):
					movement.append(nt.tile)
					if nt.value < hero.get_speed():
						to_check.append(nt)
			checked_tiles.append(t.tile)
	_update_highlighted_cells(movement)
	return movement

func _get_neighbors(tile):
	var neighbors = []
	neighbors.append(tile + NORTH_NEIGHBOR)
	neighbors.append(tile + WEST_NEIGHBOR)
	neighbors.append(tile + EAST_NEIGHBOR)
	neighbors.append(tile + SOUTH_NEIGHBOR)
	return neighbors

func _can_move(tile):
	if not _is_tile_blocked(get_cellv(tile)) and not _is_tile_taken(tile):
		overlay_map.set_cell(tile.x,tile.y,TILE_OK)
		return true
	return false

func _update_highlighted_cells(movement):
	highlighted_tiles.clear()
	highlighted_tiles += movement

func _execute_effects(effects,targets = null):
	var caster = turn_order[current_fighter]
	for effect in effects:
		effect_methods.execute(effect,effect.get_method(),targets,caster)

func _toggle_actor_lights_off():
	for actor in turn_order:
		actor.toggle_light(false)
		fog_map.set_cellv(actor.get_current_tile(),-1)

func _is_in_melee_range(origin_tile,target_tile):
	if (origin_tile + NORTH_NEIGHBOR) == target_tile:
		return true
	if (origin_tile + NORTH_EAST_NEIGHBOR) == target_tile:
		return true
	if (origin_tile + EAST_NEIGHBOR) == target_tile:
		return true
	if (origin_tile + SOUTH_EAST_NEIGHBOR) == target_tile:
		return true
	if (origin_tile + SOUTH_NEIGHBOR) == target_tile:
		return true
	if (origin_tile + SOUTH_WEST_NEIGHBOR) == target_tile:
		return true
	if (origin_tile + NORTH_WEST_NEIGHBOR) == target_tile:
		return true
	return false

func _on_actor_movement_started():
	can_act = false

func _on_actor_reached_destination():
	can_act = true

func _on_actor_killed(actor):
	turn_order.erase(actor)
	enemy_party.erase(actor)
	player_party.erase(actor)
	tile_taken.erase(actor.get_current_tile())
	if enemy_party.size() == 0:
		_end_battle()
		return
	if player_party.size() == 0:
		print("GAME OVER")
		_end_battle()

func _on_hud_ready():
	_begin_first_turn()

func _on_skill_selected(skill):
	active_skill = skill
	var origin_tile = turn_order[current_fighter].get_current_tile()
	var target_tile
	var skill_range = skill.get_range()
	match skill.get_target():
		GlobalVars.skill_target.SELF:
			_execute_effects(skill.get_effects())
		GlobalVars.skill_target.ENEMY:
			cell_mode = NPC_SELECTION
			turn_order[current_fighter].toggle_light(true)
			for enemy in enemy_party:
				target_tile = enemy.get_current_tile()
				if skill_range != GlobalVars.skill_range.MELEE or (skill_range == GlobalVars.skill_range.MELEE and _is_in_melee_range(origin_tile,target_tile)):
					enemy.toggle_light(true)
					viable_target.append(enemy)
				canvas_modulate.visible = true
		GlobalVars.skill_target.ENEMIES_ALL:
			var targets = enemy_party
			_execute_effects(skill.get_effects(),targets)
		GlobalVars.skill_target.ALLY:
			cell_mode = NPC_SELECTION
			turn_order[current_fighter].toggle_light(true)
			for hero in player_party:
				target_tile = hero.get_current_tile()
				if skill_range != GlobalVars.skill_range.MELEE or (skill_range == GlobalVars.skill_range.MELEE and _is_in_melee_range(origin_tile,target_tile)):
					hero.toggle_light(true)
					viable_target.append(hero)
				canvas_modulate.visible = true
		GlobalVars.skill_target.ALLIES_ALL:
			var targets = player_party
			_execute_effects(skill.get_effects(),targets)
		GlobalVars.skill_target.SPACE:
			cell_mode = SPACE_SELECTION
			tile_left = turn_order[current_fighter].get_current_tile()
			for actor in turn_order:
				target_tile = actor.get_current_tile()
				fog_map.set_cellv(target_tile,2)

func _on_skill_canceled():
	_prepare_for_next_turn()

func _on_skill_executed():
	cell_mode = NORMAL
	next_turn()

func _on_actor_selected(actor):
	if cell_mode == NPC_SELECTION and viable_target.find(actor) != -1:
		viable_target.clear()
		var targets = [actor]
		_execute_effects(active_skill.get_effects(),targets)

func _on_tile_selected(tile):
	if cell_mode == SPACE_SELECTION and tile_taken.find(tile) == -1:
		fog_map.set_cellv(tile_left,-1)
		var targets = [tile]
		_execute_effects(active_skill.get_effects(),targets)
