extends CellHUD

onready var skill_scene = preload("res://interface/scenes/SkillButton.tscn")

onready var turn_label: Label = $MarginContainer/VBoxContainer/TopContainer/TurnLabel
onready var ready_label: Label = $MarginContainer/VBoxContainer/MiddleContainer/ReadyLabel
onready var skills_container = $MarginContainer/VBoxContainer/BottomContainer/SkillsContainer
onready var buttons_container = $MarginContainer/VBoxContainer/BottomContainer/SkillsContainer/ButtonContainer

func update_ready_label(show):
	ready_label.visible = show
	
func update_turn_label(text):
	turn_label.text = text

func update_skills_menu(skills):
	skills_container.show()
	_instance_skills(skills)

func clear_skills_menu():
	for item in buttons_container.get_children():
		item.queue_free()

func _instance_skills(skills):
	var new_scene
	for skill in skills:
		new_scene = skill_scene.instance()
		buttons_container.add_child(new_scene)
		new_scene.set_data(skill)



