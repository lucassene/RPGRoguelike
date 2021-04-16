extends GridContainer

onready var west_button = $WestButton
onready var north_button = $NorthButton
onready var east_button = $EastButton
onready var west_label: Label = $WestButton/WestLabel
onready var north_label: Label = $NorthButton/NorthLabel
onready var east_label: Label = $EastButton/EastLabel

var cell_data
var north_type
var west_type
var east_type

func initialize(data):
	cell_data = data

func update_menu(exits):
	_reset_menu()
	for exit in exits:
		match exit.direction:
			GlobalVars.direction.WEST:
				west_button.modulate.a = 1.0
				west_button.mouse_filter = MOUSE_FILTER_STOP
				west_type = exit.type
				west_label.text = cell_data.get_cell_type_desc(exit.type)
			GlobalVars.direction.NORTH:
				north_button.modulate.a = 1.0
				north_button.mouse_filter = MOUSE_FILTER_STOP
				north_type = exit.type
				north_label.text = cell_data.get_cell_type_desc(exit.type)
			GlobalVars.direction.EAST:
				east_button.modulate.a = 1.0
				east_button.mouse_filter = MOUSE_FILTER_STOP
				east_type = exit.type
				east_label.text = cell_data.get_cell_type_desc(exit.type)

func _reset_menu():
	north_type = null
	west_type = null
	east_type = null
	west_label.text = ""
	north_label.text = ""
	east_label.text = ""
	west_button.modulate.a = 0.0
	west_button.mouse_filter = MOUSE_FILTER_IGNORE
	north_button.modulate.a = 0.0
	north_button.mouse_filter = MOUSE_FILTER_IGNORE
	east_button.modulate.a = 0.0
	east_button.mouse_filter = MOUSE_FILTER_IGNORE

func _on_WestButton_gui_input(event):
	if event is InputEventScreenTouch and event.is_pressed():
		EventHub.emit_signal("hud_direction_pressed",GlobalVars.direction.WEST,west_type)
		_reset_menu()

func _on_NorthButton_gui_input(event):
	if event is InputEventScreenTouch and event.is_pressed():
		EventHub.emit_signal("hud_direction_pressed",GlobalVars.direction.NORTH,north_type)
		_reset_menu()

func _on_EastButton_gui_input(event):
	if event is InputEventScreenTouch and event.is_pressed():
		EventHub.emit_signal("hud_direction_pressed",GlobalVars.direction.EAST,east_type)
		_reset_menu()
