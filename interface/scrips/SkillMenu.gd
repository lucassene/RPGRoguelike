extends ScrollContainer

onready var skill_scene = preload("res://interface/scenes/SkillButton.tscn")
onready var button_container = $ButtonContainer

func _ready():
	EventHub.connect("hero_turn_begin",self,"_on_hero_turn_begin")

func clear_skills_menu():
	for item in button_container.get_children():
		item.queue_free()

func _instance_skills(skills):
	var new_scene
	for skill in skills:
		new_scene = skill_scene.instance()
		button_container.add_child(new_scene)
		new_scene.set_data(skill)

func _on_hero_turn_begin(skills):
	clear_skills_menu()
	show()
	_instance_skills(skills)

