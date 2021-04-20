extends Control

onready var dungeon_scene = preload("res://levels/scenes/Dungeon.tscn")

func _on_Explore_pressed():
	get_tree().change_scene_to(dungeon_scene)

func _on_Quit_pressed():
	get_tree().quit()

func _on_ManageParty_pressed():
	pass # Replace with function body.
