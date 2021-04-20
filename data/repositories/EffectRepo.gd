extends Resource

var effect_dao = "res://data/daos/EffectDAO.gd"

func _init():
	effect_dao = load(effect_dao).new()
	
func get_effect_info(effect_id):
	return effect_dao.get_effect_info(effect_id)

func get_end_effect():
	var end_effect = {
		ID = 0,
		desc = "Ends your turn.",
		baseValue = 0,
		baseModifier = 0,
		magStat = null,
		method = "end_turn"
	}
	return end_effect
