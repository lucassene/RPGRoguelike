var effect_dataset = "res://data/datasets/EffectDataSet.gd"
var effect_repo

const no_target = [1,4,5,6]

var id: int
var name: String setget ,get_name
var range_id: int setget ,get_range
var target_id: int setget ,get_target
var effects = [] setget ,get_effects

func get_name():
	return name

func get_range():
	return range_id

func get_target():
	return target_id

func get_effects():
	return effects

func need_target_chosen():
	if no_target.find(target_id) != -1:
		return false
	return true

func _init(_effect_repo,skill):
	effect_repo = _effect_repo
	effect_dataset = load(effect_dataset)
	id = skill.ID
	name = skill.name
	range_id = skill.rangeID
	target_id = skill.targetID
	_add_effects(skill)

func _add_effects(skill):
	var effect
	if skill.effect1ID == 0:
		effect = effect_repo.get_end_effect()
		effect = effect_dataset.new(effect)
		effects.append(effect)
		return
	if skill.effect1ID != null:
		effect = effect_repo.get_effect_info(skill.effect1ID)
		effect = effect_dataset.new(effect)
		effects.append(effect)
	if skill.effect2ID != null:
		effect = effect_repo.get_effect_info(skill.effect2ID)
		effect = effect_dataset.new(effect)
		effects.append(effect)
	if skill.effect3ID != null:
		effect = effect_repo.get_effect_info(skill.effect3ID)
		effect = effect_dataset.new(effect)
		effects.append(effect)
