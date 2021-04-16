extends Control

onready var token: TextureRect = $Container/TokenTexture
onready var name_label: Label = $Container/VBoxContainer/NameLabel
onready var health_label: Label = $Container/VBoxContainer/HBoxContainer/HealthContainer/HealthLabel
onready var attack_label: Label = $Container/VBoxContainer/HBoxContainer/AttackContainer/AttackLabel
onready var magic_label: Label = $Container/VBoxContainer/HBoxContainer/MagicContainer/MagicLabel
onready var speed_label: Label = $Container/VBoxContainer/HBoxContainer/SpeedContainer/SpeedLabel
onready var defense_label: Label = $Container/VBoxContainer/HBoxContainer/DefenseContainer/DefenseLabel

signal founder_selected

var hero

func initialize(_hero):
	hero = _hero
	token.texture = load(hero.token_path)
	name_label.text = hero.name
	health_label.text = str(hero.base_health)
	attack_label.text = str(hero.base_attack)
	magic_label.text = str(hero.base_magic)
	speed_label.text = str(hero.base_speed)
	defense_label.text = str(hero.base_defense)

func _on_Container_gui_input(event):
	if event is InputEventScreenTouch and event.is_pressed():
		emit_signal("founder_selected",hero)
