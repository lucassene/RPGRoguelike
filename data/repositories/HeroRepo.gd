var hero_dao = "res://data/daos/HeroDAO.gd"

func _init():
	hero_dao = load(hero_dao).new()

func get_heroes_in_party():
	var heroes = hero_dao.get_heroes_in_party()
	return heroes

func get_hero_skills(hero_id):
	var skills = hero_dao.get_hero_skills(hero_id)
	return skills

func insert_new_hero(hero):
	return hero_dao.insert_new_hero(hero)
