extends Resource

const HERO_TABLE = "hero"
const HERO_SKILL_TABLE = "hero_skill"
const HERO_EQUIP_TABLE = "hero_equip"

static func get_heroes_in_party():
	var query = "SELECT * FROM hero WHERE inParty = 1"
	return DataAccess.query(query)

static func get_hero_skills(hero_id):
	var query = "SELECT skill.* FROM hero_skill INNER JOIN skill ON hero_skill.skillID = skill.ID WHERE hero_skill.heroID = %s" % hero_id
	return DataAccess.query(query)

static func get_hero_equipment(hero_id):
	var query = "SELECT equip.* from hero_equip INNER JOIN equip ON hero_equip.equipID = equip.ID WHERE hero_equip.heroID = %s" % hero_id
	return DataAccess.query(query)

static func insert_new_hero(hero):
	return DataAccess.insert(HERO_TABLE,hero)
