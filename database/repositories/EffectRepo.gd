var effect_dao = "res://database/daos/EffectDAO.gd"

func _init():
	effect_dao = load(effect_dao).new()
	
func get_effect_info(effect_id):
	return effect_dao.get_effect_info(effect_id)
