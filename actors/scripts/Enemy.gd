extends Actor

onready var name_label: Label = $ColorRect/NameLabel

func initialize(actor_repo,actor,cell):
	.initialize(actor_repo,actor,cell)
	stats.id = actor.ID
	stats.actor_name = actor.name
	stats.max_health = actor.max_health
	stats.speed = actor.speed
	stats.move_type = actor.moveType
	name_label.text = stats.actor_name

