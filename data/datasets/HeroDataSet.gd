extends Resource

var skill_dataset = "res://data/datasets/SkillDataSet.gd"
var equip_dataset = "res://data/datasets/EquipDataSet.gd"
var effect_repo

var id: int setget ,get_id
var name: String setget ,get_name
var max_health: int setget ,get_max_health
var current_health: int setget ,get_current_health
var base_speed: int
var current_speed: int setget ,get_speed
var base_attack: int
var base_magic: int 
var base_defense: int 
var stats = {}
var skills = [] setget set_skills,get_skills
var equips = []

func _init(hero):
	effect_repo = RepoHub.get_effect_repo()
	skill_dataset = load(skill_dataset)
	equip_dataset = load(equip_dataset)
	id = hero.ID
	name = hero.name
	max_health = hero.maxHealth
	current_health = hero.maxHealth
	base_speed = hero.baseSpeed
	current_speed = hero.baseSpeed
	base_attack = hero.baseAttack
	base_magic = hero.baseMagic
	base_defense = hero.baseDefense
	stats = {
		attack = hero.baseAttack,
		magic = hero.baseMagic,
		defense = hero.baseDefense
	}
	skills = []
	equips = []

func get_id():
	return id

func get_name():
	return name

func get_max_health():
	return max_health

func get_current_health():
	return current_health

func get_speed():
	return current_speed

func set_skills(_skills):
	var new_skill
	for skill in _skills:
		new_skill = skill_dataset.new(skill)
		skills.append(new_skill)
	_add_end_turn_skill()

func get_skills():
	return skills

func has_skills():
	if skills.size() > 0:
		return true
	return false

func add_skill(skill):
	var new_skill = skill_dataset.new(skill)
	skills.append(new_skill)

func get_stat(stat):
	return stats[stat]

func set_equipment(equipment):
	var new_equip
	for equip in equipment:
		new_equip = equip_dataset.new(equip)
		stats[new_equip.base_stat] += new_equip.base_value
		equips.append(new_equip)

func apply_damage(value):
	if value <= 0:
		current_health += int(clamp(abs(value),0,max_health))
		return value
	else:
		var damage = int(max(0,value - stats.defense))
		current_health -= int(clamp(damage,0,max_health))
		return damage

func modify_defense(value):
	stats.defense += int(ceil(value))
	return stats.defense

func is_dead():
	if current_health <= 0:
		return true
	return false

func _add_end_turn_skill():
	var end_skill = {
		ID = 0,
		name = "End Turn",
		rangeID = GlobalVars.skill_range.SELF,
		targetID = GlobalVars.skill_target.SELF,
		selectorID = GlobalVars.skill_selector.SELF,
		areaID = GlobalVars.skill_area.TILE,
		effect1ID = 0,
		effect2ID = null,
		effect3ID = null
	}
	add_skill(end_skill)
