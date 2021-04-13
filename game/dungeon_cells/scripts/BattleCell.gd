extends DungeonCell

const TURN_TEMPLATE = "%s's turn"

var current_turn = 0
var current_fighter = 0
var turn_order = []
var can_act = true

func _ready():
	can_act = true
	in_battle = true
	current_turn = 0
	current_fighter = 0

func _input(event):
	if can_act and event.is_action_pressed("next_turn") and current_turn > 0:
		_next_turn()
		return
	if can_act and event.is_action_pressed("end_battle") and current_turn > 0:
		_end_battle()
		return
	if event is InputEventScreenTouch and event.is_pressed():
		var tile_touched = world_to_map(event.position)
		if highlighted_tiles.find(tile_touched) != -1:
			_tile_action(tile_touched)

func initialize_hud():
	.initialize_hud()
	cell_hud.update_ready_label(true)
	yield(get_tree().create_timer(2.0),"timeout")
	cell_hud.update_ready_label(false)
	_begin_first_turn()

func _begin_first_turn():
	turn_order = player_party + enemy_party
	_connect_signals()
	current_turn = 1
	current_fighter = 0
	turn_order[current_fighter].begin_turn()
	_update_turn_label()

func _connect_signals():
	for actor in turn_order:
		actor.connect("destination_reached",self,"_on_actor_reached_destination")
		actor.connect("movement_started",self,"_on_actor_movement_started")
		actor.connect("skills_loaded",self,"_on_actor_skills_loaded")

func _next_turn():
	_change_turn()
	turn_order[current_fighter].end_turn()
	current_turn += 1
	current_fighter += 1
	if current_fighter >= turn_order.size():
		current_fighter = 0
	turn_order[current_fighter].begin_turn()
	_update_turn_label()

func _update_turn_label():
	cell_hud.update_turn_label(TURN_TEMPLATE % turn_order[current_fighter].stats.actor_name)

func _change_turn():
	_clear_highlighted_tiles()
	cell_hud.clear_skills_menu()

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
	turn_order[current_fighter].end_turn()
	current_fighter = 0
	current_turn = 0
	turn_order.clear()
	_clear_npcs()
	in_battle = false
	dungeon.end_battle()

func _on_actor_movement_started():
	can_act = false

func _on_actor_reached_destination():
	can_act = true

func _on_actor_skills_loaded(skills):
	cell_hud.update_skills_menu(skills)
