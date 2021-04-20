extends CenterContainer

onready var name_label: Label = $Button/NameLabel
onready var button = $Button

const target_needed = [GlobalVars.skill_target.ALLY,GlobalVars.skill_target.ENEMY,GlobalVars.skill_target.SPACE]
var skill

func get_drag_data(_position):
	if target_needed.find(skill.get_target()) != -1:
		var preview = button.duplicate()
		set_drag_preview(preview)
		return self

func set_data(data):
	skill = data
	name_label.text = skill.name
	
func _on_Button_button_down():
	EventHub.emit_signal("skill_selected",skill)
