extends Actor

onready var name_label: Label = $ColorRect/NameLabel

var dataset_path = "res://data/datasets/EnemyDataSet.gd"

func initialize(actor_repo,skill_repo,effect_repo,actor,cell):
	actor_dataset = load(dataset_path).new(actor)
	name_label.text = actor_dataset.get_name()
	.initialize(actor_repo,skill_repo,effect_repo,actor,cell)


