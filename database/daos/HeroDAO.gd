const HERO_TABLE = "hero"
const HERO_SKILLS_TABLE = "hero_skills"

static func get_heroes_in_party():
	var query = "SELECT * FROM hero WHERE inParty = 1"
	return DataAccess.query(query)

static func get_hero_skills(hero_id):
	var query = "SELECT skill.* FROM hero_skills INNER JOIN skill ON hero_skills.skillID = skill.ID WHERE hero_skills.heroID = %s" % hero_id
	return DataAccess.query(query)



