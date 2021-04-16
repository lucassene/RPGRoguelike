var skill_dataset = "res://data/datasets/SkillDataSet.gd"
var effect_repo

var id: int setget ,get_id
var name: String setget ,get_name
var max_health: int setget ,get_max_health
var current_health: int
var base_speed: int
var current_speed: int setget ,get_speed
var base_attack: int
var attack: int
var base_magic: int 
var magic: int
var base_defense: int 
var defense: int
var skills = [] setget set_skills,get_skills

func _init(hero,_effect_repo):
	effect_repo = _effect_repo
	skill_dataset = load(skill_dataset)
	id = hero.ID
	name = hero.name
	max_health = hero.maxHealth
	current_health = hero.maxHealth
	base_speed = hero.baseSpeed
	current_speed = hero.baseSpeed
	base_attack = hero.baseAttack
	attack = hero.baseAttack
	base_magic = hero.baseMagic
	magic = hero.baseMagic
	base_defense = hero.baseDefense
	defense = hero.baseDefense
	skills = []

func get_id():
	return id

func get_name():
	return name

func get_max_health():
	return max_health

func get_speed():
	return current_speed

func set_skills(_skills):
	var new_skill
	for skill in _skills:
		new_skill = skill_dataset.new(effect_repo,skill)
		skills.append(new_skill)
	_add_end_turn_skill()

func get_skills():
	return skills

func has_skills():
	if skills.size() > 0:
		return true
	return false

func add_skill(skill):
	var new_skill = skill_dataset.new(effect_repo,skill)
	skills.append(new_skill)

func get_stat(stat):
	return get(stat)

func apply_damage(value):
	if value <= 0:
		current_health -= int(clamp(value,0,max_health))
		return value
	else:
		var damage = int(max(0,value - defense))
		current_health -= int(clamp(damage,0,max_health))
		return damage

func modify_defense(value):
	defense += int(ceil(value))
	return defense

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
		effect1ID = 0,
		effect2ID = null,
		effect3ID = null
	}
	add_skill(end_skill)
