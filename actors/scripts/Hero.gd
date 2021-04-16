extends Actor

onready var name_label: Label = $ColorRect/NameLabel

var dataset_path = "res://data/datasets/HeroDataSet.gd"

func initialize(actor_repo,skill_repo,effect_repo,actor,cell):
	actor_dataset = load(dataset_path).new(actor,effect_repo)
	name_label.text = actor_dataset.get_name()
	.initialize(actor_repo,skill_repo,effect_repo,actor,cell)
	_add_skills()

func fade_out():
	tween.interpolate_property(self,"modulate:a",1.0,0.0,0.5,Tween.TRANS_LINEAR,Tween.EASE_OUT)
	tween.start()

func spawn(spawn_tile,spawn_position):
	.spawn(spawn_tile,spawn_position)
	tween.interpolate_property(self,"modulate:a",0.0,1.0,0.5,Tween.TRANS_LINEAR,Tween.EASE_OUT)
	tween.start()

func begin_turn():
	.begin_turn()
	EventHub.emit_signal("hero_turn_begin",actor_dataset.get_skills())
	parent_cell.calculate_movement(current_tile,actor_dataset)

func _add_skills():
	var skills = actor_repo.get_hero_skills(actor_dataset.get_id())
	actor_dataset.set_skills(skills)

