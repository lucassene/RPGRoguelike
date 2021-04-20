extends Resource

const SKILL_TABLE = "skill"
const HERO_SKILL_TABLE = "hero_skill"
const RANGE_TABLE = "range"
const TARGET_TABLE = "target"

static func insert_hero_skill(skill):
	return DataAccess.insert(HERO_SKILL_TABLE,skill)
	




