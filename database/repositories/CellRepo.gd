var cells_dao_path = "res://database/daos/CellsDAO.gd"
var cells_dao

func _init():
	randomize()
	cells_dao = load(cells_dao_path).new()

func get_random_cell(type):
	var random
	var results = cells_dao.get_cell_scenes_by_type(type)
	random = randi() % results.size()
	return results[random].path

func get_random_cell_type(current_type):
	var possible_types = cells_dao.get_possible_cell_types(current_type)
	var random = randi() % 100
	for x in range(possible_types.size(),0,-1):
		var index = x -1
		if random >= possible_types[index].chance:
			return possible_types[index].nextTypeID

func get_first_cell_type():
	var random
	var types = cells_dao.get_cell_type_by_group(cells_dao.group.SHOP)
	random = randi() % types.size()
	return types[random].ID

func get_shop_id():
	return cells_dao.group.SHOP

func get_forbidden_cells(type):
	var forbidden_types = cells_dao.get_forbidden_cells_by_type(type)
	return forbidden_types

func get_npcs_needed(type):
	var npcs_needed = cells_dao.get_npcs_by_type(type)
	return npcs_needed

func get_cell_type_desc(type):
	var desc = cells_dao.get_cell_type_desc(type)
	return desc

func get_cell_group(type):
	var group = cells_dao.get_cell_group_by_type(type)
	return group
