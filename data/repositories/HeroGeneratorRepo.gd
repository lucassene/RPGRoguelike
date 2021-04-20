extends Resource

var equip_repo = "res://data/repositories/EquipRepo.gd"
var hero_gen_dao = "res://data/daos/HeroGeneratorDAO.gd"

enum {FEMALE,MALE}

const HEALTH = [8,9,10,11,12]
const STAT = [1,2]

var gender_selected = []
var hero = {
	ID = null,
	name = "",
	gender = 0,
	tokenPath = "",
	inParty = 1,
	maxHealth = 0,
	baseSpeed = 0,
	baseAttack = 0,
	baseMagic = 0,
	baseDefense = 0,
}

func _init():
	randomize()
	hero_gen_dao = load(hero_gen_dao).new()
	equip_repo = load(equip_repo).new()
	gender_selected.clear()

func get_random_hero():
	var gender = randi() % 2
	gender_selected.append(gender)
	if gender_selected.size() == 3:
		if gender_selected.find(FEMALE) == -1:
			gender = FEMALE
		if gender_selected.find(MALE) == -1:
			gender = MALE
	var options = hero_gen_dao.get_hero_names_by_gender(gender)
	var random = randi() & options.size() - 1
	hero.name = options[random].string
	hero.gender = gender
	hero.tokenPath = _get_random_hero_token()
	hero.maxHealth = _get_random_value(HEALTH)
	hero.baseSpeed = _get_random_value(STAT)
	hero.baseAttack = _get_random_value(STAT)
	hero.baseMagic = _get_random_value(STAT)
	_get_equipment()
	return hero.duplicate()

func _get_equipment():
	if hero.baseAttack > hero.baseMagic:
		hero.equips = equip_repo.get_first_equipment(equip_repo.NORMAL)
		_update_speed()
	elif hero.baseMagic > hero.baseAttack:
		hero.equips = equip_repo.get_first_equipment(equip_repo.MAGICAL)
	else:
		var random = randi() % 100
		if random >= 50:
			hero.equips = equip_repo.get_first_equipment(equip_repo.NORMAL)
		else:
			hero.equips = equip_repo.get_first_equipment(equip_repo.MAGICAL)

func _update_speed():
	for equip in hero.equips:
		if equip.ID == equip_repo.melee_weapon.SHORTSWORD or equip.ID == equip_repo.melee_weapon.GREATAXE:
			hero.baseSpeed += 1
			break

func _get_random_hero_token():
	var options = hero_gen_dao.get_hero_tokens()
	var random = randi() % options.size() - 1
	return options[random].path

func _get_random_value(variable):
	var random = randi() % variable.size()
	return variable[random]
