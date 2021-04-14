enum {END_TURN_EFFECT = 6}

var skill_dao = "res://database/daos/SkillDAO.gd"

func _init():
	skill_dao = load(skill_dao).new()

func get_end_turn_skill():
	var skill = {
		name = "End Turn",
		rangeID = GlobalVars.skill_range.SELF,
		targetID = GlobalVars.skill_target.SELF,
		effect1ID = END_TURN_EFFECT,
		effect2ID = null,
		effect3ID = null
	}
	return skill

