extends Node

const cell_repo_path = "res://data/repositories/CellRepo.gd"
var cell_repo

const hero_repo_path = "res://data/repositories/HeroRepo.gd"
var hero_repo

const skill_repo_path = "res://data/repositories/SkillRepo.gd"
var skill_repo

const enemy_repo_path = "res://data/repositories/EnemyRepo.gd"
var enemy_repo

const effect_repo_path = "res://data/repositories/EffectRepo.gd"
var effect_repo

func _get_repository(path,repo):
	if repo: return repo
	repo = load(path).new()
	return repo

func get_skill_repo():
	return _get_repository(skill_repo_path,skill_repo)

func get_cell_repo():
	return _get_repository(cell_repo_path,cell_repo)

func get_hero_repo():
	return _get_repository(hero_repo_path,hero_repo)

func get_enemy_repo():
	return _get_repository(enemy_repo_path,enemy_repo)

func get_effect_repo():
	return _get_repository(effect_repo_path,effect_repo)
