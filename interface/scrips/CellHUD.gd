extends Control
class_name CellHUD

onready var cell_label: Label = $MarginContainer/VBoxContainer/TopContainer/CellLabel

func initialize():
	pass

func set_cell_label(cell_name):
	cell_label.text = cell_name

