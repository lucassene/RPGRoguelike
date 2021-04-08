extends Control

onready var navigation_menu = $MarginContainer/NavigationMenu

signal direction_pressed(direction)

func set_exits(exits):
	navigation_menu.set_buttons_visibility(exits)

func _on_NavigationMenu_direction_pressed(direction):
	emit_signal("direction_pressed",direction)
