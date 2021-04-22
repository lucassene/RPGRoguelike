extends CenterContainer

onready var name_label: Label = $Button/NameLabel
onready var button = $Button
onready var texture = $SkillTexture
onready var preview_name = $SkillTexture/PreviewName

const target_needed = [GlobalVars.skill_target.ALLY,GlobalVars.skill_target.ENEMY,GlobalVars.skill_target.SPACE,GlobalVars.skill_target.ALL]
var skill

func get_drag_data(_position):
	if target_needed.find(skill.get_target()) != -1:
		var preview = texture.duplicate()
		preview.visible = true
		set_drag_preview(preview)
		EventHub.emit_signal("skill_drag_started")
		return preview

func set_data(data):
	skill = data
	name_label.text = skill.name
	preview_name.text = skill.name

func _on_Button_button_down():
	EventHub.emit_signal("skill_selected",skill)
