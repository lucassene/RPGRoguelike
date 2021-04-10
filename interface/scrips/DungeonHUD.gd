extends Control

onready var navigation_menu = $MarginContainer/NavigationMenu

signal direction_pressed(direction,cell_type)

func set_exits(exits):
	navigation_menu.update_menu(exits)

func _on_NavigationMenu_direction_pressed(direction,cell_type):
	emit_signal("direction_pressed",direction,cell_type)
