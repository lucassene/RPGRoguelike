extends Node

var cell_0 = "res://game/dungeon_cells/scenes/CELL_00.tscn"
var cell_1 = "res://game/dungeon_cells/scenes/CELL_01.tscn"
var cell_2 = "res://game/dungeon_cells/scenes/CELL_02.tscn"

var total_cells = 3
var cell_list = []

func initialize():
	for x in range(total_cells):
		var variable = "cell_" + str(x)
		cell_list.append(get(variable))

func get_random_cell():
	randomize()
	var random = randi() % cell_list.size()
	return cell_list[random]
