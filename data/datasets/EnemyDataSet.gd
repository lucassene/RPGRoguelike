var id: int
var name: String setget ,get_name
var max_health: int setget ,get_max_health
var current_health: int
var base_speed: int
var speed: int
var base_defense: int
var defense: int

func _init(enemy):
	id = enemy.ID
	name = enemy.name
	max_health = enemy.maxHealth
	current_health = enemy.maxHealth
	base_speed = enemy.baseSpeed
	speed = enemy.baseSpeed
	base_defense = enemy.baseDefense
	defense = enemy.baseDefense

func get_name():
	return name

func get_max_health():
	return max_health

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
