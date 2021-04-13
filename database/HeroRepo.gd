extends Resource

var hero_dao_path = "res://database/daos/HeroDAO.gd"
var hero_dao

func initialize():
	hero_dao = load(hero_dao_path).new()

func get_heroes_in_party():
	var heroes = hero_dao.get_heroes_in_party()
	return heroes

func get_hero_skills(hero_id):
	var skills = hero_dao.get_hero_skills(hero_id)
	return skills

