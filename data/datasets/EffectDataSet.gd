extends Resource

var id: int
var desc: String
var base_value: int
var base_modifier: float
var mag_stat: String
var method: String setget ,get_method

func _init(effect):
	id = effect.ID
	desc = effect.desc
	base_value = effect.baseValue
	base_modifier = effect.baseModifier
	if effect.magStat != null: mag_stat = effect.magStat
	method = effect.method

func get_method():
	return method

func get_magnitude_stat():
	return mag_stat

func get_base_modifier():
	return base_modifier

func get_base_value():
	return base_value

