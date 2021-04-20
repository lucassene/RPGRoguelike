extends Resource

var id: int
var name: String
var desc: String
var type: int
var slot: int
var base_stat: String
var base_value: int
var base_skill: int

func _init(equip):
	id = equip.ID
	name = equip.name
	desc = equip.desc
	type = equip.typeID
	slot = equip.slotID
	base_stat = equip.baseStat
	base_value = equip.baseValue
	if equip.baseSkillID: base_skill = equip.baseSkillID
