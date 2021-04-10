extends Node

enum {BATTLE,RESCUE,REST,SHOP}
var cell_type = [BATTLE,RESCUE,REST,SHOP]
var type_strings = {
	BATTLE: "Battle",
	RESCUE: "Rescue",
	REST: "Rest",
	SHOP: "Shop"
}

var battle_cells = [
	"res://game/dungeon_cells/scenes/prototype/battle/ProtCell_BT00.tscn"
]
var rest_cells = [
	"res://game/dungeon_cells/scenes/prototype/rest/ProtCell_RT00.tscn"
]
var shop_cells = [
	"res://game/dungeon_cells/scenes/prototype/shop/ProtCell_SP00.tscn"
]

func _ready():
	randomize()

func get_random_cell(type):
	var random
	match type:
		BATTLE,RESCUE:
			random = randi() % battle_cells.size()
			return battle_cells[random]
		SHOP:
			random = randi() % shop_cells.size()
			return shop_cells[random]
		REST:
			random = randi() % rest_cells.size()
			return rest_cells[random]

func get_random_cell_type(forbidden_types = null):
	var random
	var can_choose = false
	var type
	if forbidden_types and forbidden_types.size() >= 1:
		while can_choose == false:
			random = randi() % cell_type.size()
			type = cell_type[random]
			if forbidden_types.find(type) == -1:
				can_choose = true
	else:
		random = randi() % cell_type.size()
		type = cell_type[random]
	return type

func get_npcs_needed(type):
	var npcs_needed = []
	match type:
		BATTLE:
			npcs_needed = [GlobalVars.ENEMY]
		SHOP:
			npcs_needed = [GlobalVars.NPC]
		RESCUE:
			npcs_needed = [GlobalVars.NPC,GlobalVars.ENEMY]
	return npcs_needed
