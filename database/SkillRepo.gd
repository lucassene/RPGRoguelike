extends Resource

enum {END_TURN_SKILL = 6}

var skill_dao_path = "res://database/daos/SkillDAO.gd"
var skill_dao

func initialize():
	skill_dao = load(skill_dao_path).new()

func get_end_turn_skill():
	var skill = {
		name = "End Turn",
		rangeID = GlobalVars.skill_range.SELF,
		targetID = GlobalVars.skill_target.SELF,
		effect1ID = END_TURN_SKILL,
		effect2ID = null,
		effect3ID = null
	}
	return skill

