extends Resource

var hero_dao = "res://data/daos/HeroDAO.gd"

func _init():
	hero_dao = load(hero_dao).new()

func has_heroes():
	var hero_count = hero_dao.count_existing_heroes()
	print(hero_count)
	if hero_count == null or hero_count <= 0:
		return false
	else:
		return true

func clear_heroes():
	hero_dao.clear_heroes()

func get_heroes_in_party():
	var heroes = hero_dao.get_heroes_in_party()
	return heroes

func get_hero_skills(hero_id):
	var skills = hero_dao.get_hero_skills(hero_id)
	return skills

func get_hero_equipment(hero_id):
	var equips = hero_dao.get_hero_equipment(hero_id)
	return equips

func insert_new_hero(hero):
	return hero_dao.insert_new_hero(hero)
