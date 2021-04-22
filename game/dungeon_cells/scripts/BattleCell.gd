extends DungeonCell

var current_turn = 0
var current_fighter = 0 setget ,get_current_fighter
var turn_order = []
var can_act = true
var highlighted_tiles = []
var active_skill
var viable_targets = []
var has_moved = false
var is_dragging = false
var drag_position = null
var last_hovered_tile
var selection_tiles = [] setget set_selection_tiles

func get_current_fighter():
	return turn_order[current_fighter]

func set_selection_tiles(value):
	selection_tiles.clear()
	selection_tiles = value

func _ready():
	can_act = true
	in_battle = true
	current_turn = 0
	current_fighter = 0
	skill_handler.initialize(self)
	EventHub.connect("start_battle",self,"_on_hud_ready")
	EventHub.connect("skill_canceled",self,"_on_skill_canceled")
	EventHub.connect("skill_executed",self,"_on_skill_executed")
	EventHub.connect("actor_selected",self,"_on_actor_selected")
	EventHub.connect("skill_drag_started",self,"_on_skill_drag_started")
	
func _input(event):
	if can_act and event.is_action_pressed("next_turn") and current_turn > 0:
		next_turn()
		return
	if can_act and event.is_action_pressed("end_battle") and current_turn > 0:
		_end_battle()
		return
	_process_screen_touch(event)
	_process_screen_drag(event)

func _physics_process(_delta):
	if is_dragging and drag_position != null:
		var tile = overlay_map.world_to_map(drag_position)
		var map_tile = world_to_map(drag_position)
		if tile != last_hovered_tile:
			if not is_tile_blocked(map_tile):
				tile_light.visible = true
				if last_hovered_tile: overlay_map.set_cellv(last_hovered_tile,-1)
				last_hovered_tile = tile
				tile_light.global_position = overlay_map.map_to_world(tile) + GlobalVars.CELL_SIZE/2
				overlay_map.set_cellv(tile,1)
				selection_tiles = calculate_selection_tiles(tile,skill_handler.get_area_value())
				_update_selection_highlight()
			else:
				tile_light.visible = false
				_clear_prior_selection()
				last_hovered_tile = null

func _process_screen_touch(event):
	if event is InputEventScreenTouch:
		var global_touch_position = get_canvas_transform().xform_inv(event.position)
		if event.is_pressed():
			var tile_touched = world_to_map(global_touch_position)
			if in_battle and cell_mode == NORMAL and _is_hero_turn() and not has_moved:
				if highlighted_tiles.find(tile_touched) != -1:
					_move_actor(tile_touched)
			elif cell_mode == EMPTY_SPACE_SELECTION or cell_mode == SPACE_SELECTION:
				_process_skill(global_touch_position)
		elif is_dragging:
			_stop_skill_drag()
			_process_skill(global_touch_position)

func _process_screen_drag(event):
	if is_dragging and event is InputEventScreenDrag:
		drag_position = get_canvas_transform().xform_inv(event.position)	

func _move_actor(tile):
	_clear_highlighted_tiles()
	has_moved = true
	var actor = turn_order[current_fighter]
	actor.move_to(tile,map_to_world(tile))
	taken_tiles[tile] = actor

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
		actor.set_health_bar_visibility(true)

func _disconnect_signals():
	for actor in turn_order:
		actor.disconnect("destination_reached",self,"_on_actor_reached_destination")
		actor.disconnect("movement_started",self,"_on_actor_movement_started")
		actor.disconnect("actor_killed",self,"_on_actor_killed")
		actor.set_health_bar_visibility(false)

func _prepare_for_next_turn():
	cell_mode = NORMAL
	_toggle_actor_lights_off()
	overlay_map.show()
	canvas_modulate.hide()

func next_turn():
	_prepare_for_next_turn()
	_change_turn()
	has_moved = false
	if turn_order.size() > 0:
		turn_order[current_fighter].end_turn()
		current_turn += 1
		current_fighter += 1
		if current_fighter >= turn_order.size():
			current_fighter = 0
		turn_order[current_fighter].begin_turn()
		EventHub.emit_signal("turn_changed",turn_order[current_fighter].get_actor_name(),_is_enemy())
		
		#Development
		if enemy_party.find(turn_order[current_fighter]) != -1:
			yield(get_tree().create_timer(1.0),"timeout")
			next_turn()
	else:
		_end_battle()

func _is_enemy():
	if enemy_party.find(turn_order[current_fighter]) != -1:
		return true
	return false

func _change_turn():
	_clear_highlighted_tiles()

func _clear_highlighted_tiles():
	if not has_moved:
		for tile in highlighted_tiles:
			overlay_map.set_cell(tile.x,tile.y,-1)

func _show_highlighted_tiles():
	if not has_moved:
		for tile in highlighted_tiles:
			overlay_map.set_cell(tile.x,tile.y,0)

func _end_battle():
	_disconnect_signals()
	if turn_order.size() > 0: turn_order[current_fighter].end_turn()
	_clear_highlighted_tiles()
	current_fighter = 0
	current_turn = 0
	turn_order.clear()
	in_battle = false
	EventHub.emit_signal("battle_ended")

func calculate_movement(_tile,speed):
	var movement = []
	var to_check = [{tile = _tile,value = 0}]
	var checked_tiles = []
	for t in to_check:
		if checked_tiles.find(t.tile) == -1:
			for n in _get_neighbors(t.tile,MOVE_NEIGHBORS):
				var nt ={tile = n,value = t.value + 1}
				if is_tile_available(n):
					overlay_map.set_cell(n.x,n.y,TILE_OK)
					movement.append(nt.tile)
					if nt.value < speed:
						to_check.append(nt)
			checked_tiles.append(t.tile)
	_update_highlighted_cells(movement)
	return movement
	
func calculate_selection_tiles(_tile,area):
	var tiles = [_tile]
	var to_check = [{tile = _tile,value = 0}]
	var checked_tiles = []
	if area > 0:
		for t in to_check:
			if checked_tiles.find(t.tile) == -1:
				for n in _get_neighbors(t.tile,MOVE_NEIGHBORS):
					var nt ={tile = n,value = t.value + 1}
					if not is_tile_blocked(n):
						tiles.append(nt.tile)
						if nt.value < area:
							to_check.append(nt)
				checked_tiles.append(t.tile)
	return tiles

func _get_neighbors(tile,list):
	var neighbors = []
	for direction in list:
		neighbors.append(tile + direction)
	return neighbors

func _update_highlighted_cells(movement):
	highlighted_tiles.clear()
	highlighted_tiles += movement

func _update_selection_highlight():
	_clear_prior_selection()
	for tile in selection_tiles:
		if not is_tile_blocked(tile):
			overlay_map.set_cellv(tile,1)

func _clear_prior_selection():
	for tile in overlay_map.get_used_cells_by_id(1):
		overlay_map.set_cellv(tile,-1)

func _toggle_actor_lights_off():
	for actor in turn_order:
		actor.toggle_light(false)
		fog_map.set_cellv(actor.get_current_tile(),-1)

func is_target_in_melee_range(origin_tile,target_tile):
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

func _is_hero_turn():
	if turn_order.size() > 0 and player_party.find(turn_order[current_fighter]) != -1:
		return true
	return false

func _stop_skill_drag():
	drag_position = null
	is_dragging = false
	_clear_prior_selection()

func _process_skill(drop_position):
	_show_highlighted_tiles()
	var tile = world_to_map(drop_position)
	var has_target = false
	match cell_mode:
		ACTOR_SELECTION:
			has_target = skill_handler.process_actor_selection(tile)
		EMPTY_SPACE_SELECTION:
			has_target = skill_handler.process_empty_space_selection(tile)
		SPACE_SELECTION:
			has_target = skill_handler.process_space_selection(tile,selection_tiles)
	if not has_target:
		_prepare_for_next_turn()

func get_current_fighter_tile():
	return turn_order[current_fighter].get_current_tile()

func set_actor_selection(tile,area):
	_clear_highlighted_tiles()
	selection_tiles = calculate_selection_tiles(tile,area)
	cell_mode = ACTOR_SELECTION
	turn_order[current_fighter].toggle_light(true)

func set_empty_space_selection():
	_clear_highlighted_tiles()
	cell_mode = EMPTY_SPACE_SELECTION
	for actor in turn_order:
		var target_tile = actor.get_current_tile()
		fog_map.set_cellv(target_tile,2)

func set_space_selection(tile,area):
	cell_mode = SPACE_SELECTION
	_clear_highlighted_tiles()
	selection_tiles = calculate_selection_tiles(tile,area)

func clear_tile_left(tile):
	fog_map.set_cellv(tile,-1)

func set_canvas_module(value):
	canvas_modulate.visible = value

func _on_actor_movement_started():
	can_act = false

func _on_actor_reached_destination():
	can_act = true

func _on_actor_killed(actor):
	turn_order.erase(actor)
	enemy_party.erase(actor)
	player_party.erase(actor)
	taken_tiles.erase(actor.get_current_tile())
	if enemy_party.size() == 0:
		_end_battle()
		return
	if player_party.size() == 0:
		print("GAME OVER")
		_end_battle()

func _on_hud_ready():
	_begin_first_turn()

func _on_skill_canceled():
	_prepare_for_next_turn()

func _on_skill_executed():
	cell_mode = NORMAL
	next_turn()

func _on_actor_selected(actor):
	if cell_mode == ACTOR_SELECTION:
		skill_handler.process_skill_on_target(actor)

func _on_skill_drag_started():
	is_dragging = true
