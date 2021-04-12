extends DungeonCell

onready var turn_label: Label = $CanvasLayer/CellHUD/MarginContainer/VBoxContainer/TopContainer/TurnLabel
onready var ready_label: Label = $CanvasLayer/CellHUD/MarginContainer/VBoxContainer/MiddleContainer/ReadyLabel

const TURN_TEMPLATE = "%s's turn"

var current_turn = 0
var current_fighter = 0
var turn_order = []

func _ready():
	current_turn = 0
	current_fighter = 0

func _input(event):
	if event.is_action_pressed("next_turn") and current_turn > 0:
		_next_turn()
		return
	if event.is_action_pressed("end_battle") and current_turn > 0:
		_end_battle()
		return
	if event is InputEventScreenTouch and event.is_pressed():
		var tile_touched = world_to_map(event.position)
		if highlighted_tiles.find(tile_touched) != -1:
			_tile_action(tile_touched)

func initialize_hud():
	.initialize_hud()
	ready_label.show()
	yield(get_tree().create_timer(2.0),"timeout")
	ready_label.hide()
	_begin_first_turn()

func _begin_first_turn():
	current_turn = 1
	current_fighter = 0
	turn_order = player_party + enemy_party
	turn_order[current_fighter].begin_turn()
	_update_turn_label()

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
	turn_label.text = TURN_TEMPLATE % turn_order[current_fighter].stats.actor_name

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
	turn_order[current_fighter].end_turn()
	current_fighter = 0
	current_turn = 0
	turn_order.clear()
	_clear_npcs()
	dungeon.end_battle()
