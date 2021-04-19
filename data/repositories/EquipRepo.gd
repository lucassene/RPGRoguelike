var equip_dao = "res://data/daos/EquipDAO.gd"

enum equip_type {WEAPON = 1, ARMOR = 2, ACCESSORY = 3}
enum slot {ONE_HAND = 1, BOTH_HANDS = 2, BODY = 3, AMULET = 4, RING = 5}
enum {NORMAL,MAGICAL}
enum melee_weapon {SHORTSWORD = 1, GREATAXE = 2}

const NORMAL_FIRST_WEAPON = [1,2,3]
const MAGICAL_FIRST_WEAPON = [4,5]
const NORMAL_OFFHAND_WEAPON = [1,8]
const MAGICAL_OFFHAND_WEAPON = [5,8]
const HIDE_ARMOR_ID = 7
const CLOTH_ROBE_ID = 6

func _init():
	randomize()
	equip_dao = load(equip_dao).new()

func get_first_equipment(type):
	var equips = []
	if type == NORMAL:
		_add_weapon(equips,NORMAL_FIRST_WEAPON,NORMAL_OFFHAND_WEAPON)
		equips.append(equip_dao.get_equip_by_id(HIDE_ARMOR_ID))
	else:
		_add_weapon(equips,MAGICAL_FIRST_WEAPON,MAGICAL_OFFHAND_WEAPON)
		equips.append(equip_dao.get_equip_by_id(CLOTH_ROBE_ID))
	return equips

func insert_hero_equip(hero_id,equip_id):
	var equip = {
		heroID = hero_id,
		equipID = equip_id,
		isEquipped = 1
	}
	return equip_dao.insert_hero_equip(equip)

func _add_weapon(equips,list,offhand_list):
	var random = randi() % list.size()
	equips.append(equip_dao.get_equip_by_id(list[random]))
	if equips[0].slotID == 1:
		random = randi() % 100
		if random >= 60:
			random = randi() % offhand_list.size()
			equips.append(equip_dao.get_equip_by_id(offhand_list[random]))
