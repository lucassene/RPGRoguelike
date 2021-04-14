extends CenterContainer

onready var name_label: Label = $Button/NameLabel

var skill

func set_data(data):
	skill = data
	name_label.text = skill.name
	
func _on_Button_pressed():
	EventHub.emit_signal("skill_selected",skill)
