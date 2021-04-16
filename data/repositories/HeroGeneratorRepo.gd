var hero_gen_dao = "res://data/daos/HeroGeneratorDAO.gd"

func _init():
	randomize()
	hero_gen_dao = load(hero_gen_dao).new()

func get_hero_name():
	var options = hero_gen_dao.get_hero_names()
	var random = randi() & options.size() - 1
	return options[random].string

func get_hero_token():
	var options = hero_gen_dao.get_hero_tokens()
	var random = randi() % options.size() - 1
	return options[random].path
