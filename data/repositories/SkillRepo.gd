enum {END_TURN_EFFECT = 6}

var skill_dao = "res://data/daos/SkillDAO.gd"

func _init():
	skill_dao = load(skill_dao).new()

