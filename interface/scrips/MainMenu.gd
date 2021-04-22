extends Control

onready var new_game_scene = preload("res://interface/scenes/BeginAdvMenu.tscn")
onready var continue_game_scene = preload("res://interface/scenes/GameHub.tscn")

onready var new_game_button: Button = $MarginContainer/VBoxContainer2/VBoxContainer/NewGame
onready var continue_button: Button = $MarginContainer/VBoxContainer2/VBoxContainer/Continue

var hero_repo
var has_game = false

func _ready():
	hero_repo = RepoHub.get_hero_repo()
	if hero_repo.has_heroes():
		has_game = true
		continue_button.show()
	else:
		has_game = false
		new_game_button.show()
		continue_button.hide()

func _on_ExitButton_pressed():
	get_tree().quit()

func _on_NewGame_pressed():
	if has_game: hero_repo.clear_heroes()
	get_tree().change_scene_to(new_game_scene)

func _on_Continue_pressed():
	get_tree().change_scene_to(continue_game_scene)
