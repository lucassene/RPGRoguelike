extends TextureButton

onready var name_label: Label = $NameLabel

var skill = {
	_name = "",
	_range = GlobalVars.skill_range.SELF,
	_target = GlobalVars.skill_target.SELF,
	_effects = []
}

func set_data(data):
	skill._name = data.name
	skill._range = data.rangeID
	skill._target = data.targetID
	skill._effects = _get_effects(data.effect1ID,data.effect2ID,data.effect3ID)
	name_label.text = skill._name
	
func _get_effects(effect1,effect2,effect3):
	if effect1 != null:
		skill._effects.append(effect1)
	if effect2 != null:
		skill._effects.append(effect2)
	if effect3 != null:
		skill._effects.append(effect3)
