extends Control

onready var navigation_menu = $VBoxContainer/BottomContainer/NavigationMenu

signal direction_pressed(direction,cell_type)

enum {EXPLORATION,BATTLE,SHOP,REST}

var cell_data
var cell_type
var mode

func initialize(data,_cell_type):
	cell_data = data
	cell_type = _cell_type
	_set_hud_mode()

func _set_hud_mode():
	mode = cell_data.get_cell_group(cell_type)
	match mode:
		BATTLE:
			_begin_battle_mode()
		SHOP:
			_begin_shop_mode()
		REST:
			_begin_rest_mode()

func _begin_battle_mode():
	navigation_menu.hide()

func _begin_shop_mode():
	navigation_menu.initialize(cell_data)

func _begin_rest_mode():
	navigation_menu.initialize(cell_data)

func begin_exploration_mode():
	navigation_menu.initialize(cell_data)

func set_exits(exits):
	navigation_menu.update_menu(exits)

func _on_NavigationMenu_direction_pressed(direction,next_cell_type):
	emit_signal("direction_pressed",direction,next_cell_type)
