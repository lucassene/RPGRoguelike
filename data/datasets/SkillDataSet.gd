extends Resource

var area_dataset = "res://data/datasets/AreaDataSet.gd"
var effect_dataset = "res://data/datasets/EffectDataSet.gd"
var effect_repo
var skill_repo

const no_target = [1,4,5,6]

var id: int
var name: String setget ,get_name
var range_id: int setget ,get_range
var target_id: int setget ,get_target
var selector_id: int setget ,get_selector
var area
var effects = [] setget ,get_effects

func get_name():
	return name

func get_range():
	return range_id

func get_target():
	return target_id

func get_selector():
	return selector_id

func get_effects():
	return effects

func get_area_value():
	return area.get_value()

func need_target_chosen():
	if no_target.find(target_id) != -1:
		return false
	return true

func _init(skill):
	skill_repo = RepoHub.get_skill_repo()
	area_dataset = load(area_dataset)
	effect_repo = RepoHub.get_effect_repo()
	effect_dataset = load(effect_dataset)
	id = skill.ID
	name = skill.name
	range_id = skill.rangeID
	target_id = skill.targetID
	selector_id = skill.selectorID
	_add_effects(skill)
	_add_infos(skill)

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

func _add_infos(skill):
	var info = skill_repo.get_skill_area(skill.areaID)
	area = area_dataset.new(info)
