extends Control

onready var founder_scene = preload("res://interface/scenes/FounderMenu.tscn")

func _on_ExitButton_pressed():
	get_tree().quit()

func _on_NewButton_pressed():
	get_tree().change_scene_to(founder_scene)

