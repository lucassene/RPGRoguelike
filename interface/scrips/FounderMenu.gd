extends Control

onready var founder_scene = preload("res://interface/scenes/FounderOption.tscn")
onready var game_hub_scene = preload("res://interface/scenes/GameHub.tscn")
onready var founder_gen = preload("res://data/repositories/HeroGeneratorRepo.gd").new()

onready var options_container = $MarginContainer/VBoxContainer/OptionsContainer

const HEALTH = Vector2(3,6)
const ATTACK = Vector2(1,3)
const MAGIC = Vector2(0,3)
const SPEED = Vector2(1,3)
const DEFENSE = Vector2(0,2)

func _ready():
	randomize()
	_generate_options()
	
func _generate_options():
	for _x in range(4):
		var founder = founder_scene.instance()
		var hero = _generate_random_hero()
		options_container.add_child(founder)
		founder.initialize(hero)
		founder.connect("founder_selected",self,"_on_founder_selected")

func _generate_random_hero():
	var hero = {
		name = founder_gen.get_hero_name(),
		token_path = founder_gen.get_hero_token(),
		base_health = _get_random_value(HEALTH),
		base_attack = _get_random_value(ATTACK),
		base_magic = _get_random_value(MAGIC),
		base_speed = _get_random_value(SPEED),
		base_defense = _get_random_value(DEFENSE)
	}
	return hero

func _get_random_value(variable):
	return int(rand_range(variable.x,variable.y))

func _on_founder_selected(_founder):
	get_tree().change_scene_to(game_hub_scene)
