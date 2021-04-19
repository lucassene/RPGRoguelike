extends Control

onready var begin_scene = preload("res://interface/scenes/BeginAdvMenu.tscn")

func _on_ExitButton_pressed():
	get_tree().quit()

func _on_NewButton_pressed():
	get_tree().change_scene_to(begin_scene)

