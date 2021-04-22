extends Resource

const SKILL_TABLE = "skill"
const HERO_SKILL_TABLE = "hero_skill"
const RANGE_TABLE = "skill_range"
const TARGET_TABLE = "skill_target"
const AREA_TABLE = "skill_area"

static func insert_hero_skill(skill):
	return DataAccess.insert(HERO_SKILL_TABLE,skill)

static func get_area(area_id):
	var query = "SELECT * from skill_area WHERE ID = %s" % area_id
	return DataAccess.query(query)[0]
	




