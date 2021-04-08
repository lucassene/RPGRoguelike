extends GridContainer

onready var west_button = $WestButton
onready var north_button = $NorthButton
onready var east_button = $EastButton

signal direction_pressed(direction)

func set_buttons_visibility(exits):
	_reset_buttons()
	for exit in exits:
		match exit:
			GlobalVars.direction.WEST:
				west_button.modulate.a = 1.0
				west_button.mouse_filter = MOUSE_FILTER_STOP
			GlobalVars.direction.NORTH:
				north_button.modulate.a = 1.0
				north_button.mouse_filter = MOUSE_FILTER_STOP
			GlobalVars.direction.EAST:
				east_button.modulate.a = 1.0
				east_button.mouse_filter = MOUSE_FILTER_STOP

func _reset_buttons():
	west_button.modulate.a = 0.0
	west_button.mouse_filter = MOUSE_FILTER_IGNORE
	north_button.modulate.a = 0.0
	north_button.mouse_filter = MOUSE_FILTER_IGNORE
	east_button.modulate.a = 0.0
	east_button.mouse_filter = MOUSE_FILTER_IGNORE

func _on_WestButton_gui_input(event):
	if event is InputEventScreenTouch and event.is_pressed():
		emit_signal("direction_pressed",GlobalVars.direction.WEST)

func _on_NorthButton_gui_input(event):
	if event is InputEventScreenTouch and event.is_pressed():
		emit_signal("direction_pressed",GlobalVars.direction.NORTH)

func _on_EastButton_gui_input(event):
	if event is InputEventScreenTouch and event.is_pressed():
		emit_signal("direction_pressed",GlobalVars.direction.EAST)
