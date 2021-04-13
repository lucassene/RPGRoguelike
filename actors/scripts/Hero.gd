extends Actor

onready var skill_repo = preload("res://database/SkillRepo.gd").new()
onready var name_label: Label = $ColorRect/NameLabel

func initialize(actor_repo,actor,cell):
	.initialize(actor_repo,actor,cell)
	skill_repo.initialize()
	stats.id = actor.ID
	stats.actor_name = actor.name
	stats.max_health = actor.maxHealth
	stats.speed = actor.baseSpeed
	stats.move_type = actor.moveType
	stats.attack = actor.baseAttack
	stats.magic = actor.baseMagic
	stats.defense = actor.baseDefense
	stats.skills = []
	name_label.text = stats.actor_name

func get_hero_name():
	return stats.actor_name

func fade_out():
	tween.interpolate_property(self,"modulate:a",1.0,0.0,0.5,Tween.TRANS_LINEAR,Tween.EASE_OUT)
	tween.start()

func spawn(spawn_tile,spawn_position):
	.spawn(spawn_tile,spawn_position)
	tween.interpolate_property(self,"modulate:a",0.0,1.0,0.5,Tween.TRANS_LINEAR,Tween.EASE_OUT)
	tween.start()

func begin_turn():
	.begin_turn()
	if stats.skills.size() == 0:
		_add_skills()
	else:
		emit_signal("skills_loaded",stats.skills)
	parent_cell.calculate_movement(current_tile,stats.speed,stats.move_type)

func _add_skills():
	DataAccess.open_database()
	stats.skills = repository.get_hero_skills(stats.id).duplicate()
	stats.skills.append(_get_end_turn_skill())
	DataAccess.close_database()
	emit_signal("skills_loaded",stats.skills)

func _get_end_turn_skill():
	return skill_repo.get_end_turn_skill()

