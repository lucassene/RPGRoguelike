extends Actor

onready var name_label: Label = $ColorRect/NameLabel

func initialize(actor,cell):
	.initialize(actor,cell)
	stats.id = actor.ID
	stats.actor_name = actor.name
	stats.max_health = actor.max_health
	stats.speed = actor.speed
	stats.move_type = actor.moveType
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
	parent_cell.calculate_movement(current_tile,stats.speed,stats.move_type)
	

