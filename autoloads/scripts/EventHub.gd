extends Node

#Interface Signals
signal hud_direction_pressed(direction,next_cell_type)
signal hero_skills_loaded(skills)
signal hud_ready
signal turn_changed(actor_name,is_enemy)
signal battle_ended
signal skill_canceled

#Game Signals
signal skill_selected(skill)
signal skill_executed()
signal actor_selected(actor)

