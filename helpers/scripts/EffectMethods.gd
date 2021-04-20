extends Node

func _get_magnitude(effect,caster):
	var value = _get_stat_value(effect,caster)
	var magnitude
	if value != null:
		magnitude = effect.get_base_value() + (value * effect.get_base_modifier())
	else:
		magnitude = effect.get_base_value() * effect.get_base_modifier()
	return magnitude

func _get_stat_value(effect,caster):
	var mag_stat = effect.get_magnitude_stat()
	var value = null
	if not mag_stat.empty():
		value = caster.get_stat(mag_stat)
	return value

func execute(effect,method,targets = null,caster = null):
	call_deferred(method,effect,targets,caster)

func end_turn(_effect,_targets,_caster):
	EventHub.emit_signal("skill_executed")

func apply_damage(effect,targets,caster):
	var magnitude = 0
	magnitude = _get_magnitude(effect,caster)
	for target in targets:
		target.apply_damage(magnitude)
	EventHub.emit_signal("skill_executed")

func modify_defense(effect,targets,caster):
	var magnitude = 0
	magnitude = _get_magnitude(effect,caster)
	for target in targets:
		target.modify_defense(magnitude)
	EventHub.emit_signal("skill_executed")

func teleport(_effect,targets,caster):
	caster.teleport_to(targets[0])
	EventHub.emit_signal("skill_executed")
