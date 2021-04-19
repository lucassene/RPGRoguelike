extends Control

onready var token: TextureRect = $Container/TokenTexture
onready var name_label: Label = $Container/VBoxContainer/NameLabel
onready var health_label: Label = $Container/VBoxContainer/StatsContainer/HealthContainer/HealthLabel
onready var attack_label: Label = $Container/VBoxContainer/StatsContainer/AttackContainer/AttackLabel
onready var magic_label: Label = $Container/VBoxContainer/StatsContainer/MagicContainer/MagicLabel
onready var speed_label: Label = $Container/VBoxContainer/StatsContainer/SpeedContainer/SpeedLabel
onready var defense_label: Label = $Container/VBoxContainer/StatsContainer/DefenseContainer/DefenseLabel
onready var equip_label: Label = $Container/VBoxContainer/EquipContainer/EquipLabel

signal hero_selected

var hero

func initialize(_hero):
	hero = _hero
	hero.attack = hero.baseAttack
	hero.magic = hero.baseMagic
	hero.defense = hero.baseDefense
	_update_equip()
	token.texture = load(hero.tokenPath)
	name_label.text = hero.name
	health_label.text = str(hero.maxHealth)
	attack_label.text = str(hero.attack)
	magic_label.text = str(hero.magic)
	speed_label.text = str(hero.baseSpeed)
	defense_label.text = str(hero.defense)

func _update_equip():
	var prior_weapon
	for equip in hero.equips:
		hero[equip.baseStat] += equip.baseValue
		if equip.typeID == 1:
			if equip_label.text.empty():
				prior_weapon = equip.ID
				equip_label.text = "A %s" % equip.name
			else:
				if equip.ID == prior_weapon:
					equip_label.text = "Two %ss" % equip.name
				else:
					equip_label.text += ", a %s" % equip.name
		else:
			equip_label.text += " and a %s." % equip.name

func _on_Container_gui_input(event):
	if event is InputEventScreenTouch and event.is_pressed():
		emit_signal("hero_selected",hero)
