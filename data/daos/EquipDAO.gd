extends Resource

const EQUIP_TABLE = "equip"
const HERO_EQUIP_TABLE = "hero_equip"

static func get_equip_by_id(equip_id):
	var query = "SELECT * from equip WHERE ID = %s" % equip_id
	return DataAccess.query(query)[0]

static func insert_hero_equip(equip):
	return DataAccess.insert(HERO_EQUIP_TABLE,equip)
