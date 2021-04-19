enum {END_TURN_EFFECT = 6}
enum {MAGIC_SKILL = 3}

var skill_dao = "res://data/daos/SkillDAO.gd"

func _init():
	skill_dao = load(skill_dao).new()

func insert_hero_skill(hero_id,skill_id):
	var skill = {
		heroID = hero_id,
		skillID = skill_id,
		slots = 1
	}
	return skill_dao.insert_hero_skill(skill)
