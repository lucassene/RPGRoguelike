extends Control

onready var adventurer_scene = preload("res://interface/scenes/HeroItem.tscn")
onready var game_hub_scene = preload("res://interface/scenes/GameHub.tscn")
onready var adventurer_gen = preload("res://data/repositories/HeroGeneratorRepo.gd").new()
onready var hero_repo = preload("res://data/repositories/HeroRepo.gd").new()
onready var skill_repo = preload("res://data/repositories/SkillRepo.gd").new()
onready var equip_repo = preload("res://data/repositories/EquipRepo.gd").new()

onready var options_container = $MarginContainer/VBoxContainer/OptionsContainer

const OPTIONS_NUMBER = 4

func _ready():
	randomize()
	_generate_options()
	
func _generate_options():
	for _x in range(OPTIONS_NUMBER):
		var adv = adventurer_scene.instance()
		var hero = adventurer_gen.get_random_hero()
		options_container.add_child(adv)
		adv.initialize(hero)
		adv.connect("hero_selected",self,"_on_hero_selected")

func _prepare_to_insert(hero):
	hero.erase("equips")
	hero.erase("attack")
	hero.erase("magic")
	hero.erase("speed")
	hero.erase("defense")

func _on_hero_selected(hero):
	var equips = hero.equips
	_prepare_to_insert(hero)
	var inserted_id = hero_repo.insert_new_hero(hero)
	if inserted_id:
		var added_skill = 0
		for equip in equips:
			equip_repo.insert_hero_equip(inserted_id,equip.ID)
			if equip.baseSkillID and equip.baseSkillID != added_skill:
				skill_repo.insert_hero_skill(inserted_id,equip.baseSkillID)
				added_skill = equip.baseSkillID
	else:
		print("Failed to insert a new hero.")
	get_tree().change_scene_to(game_hub_scene)
