extends Node

onready var effect_methods = preload("res://helpers/scripts/EffectMethods.gd").new()

var active_skill
var cell
var viable_targets = []

func _ready():
	EventHub.connect("skill_selected",self,"_on_skill_selected")

func initialize(_cell):
	cell = _cell

func get_area_value():
	return active_skill.get_area_value()

func process_actor_selection(tile):
	if tile:
		for target in viable_targets:
			if tile == target.get_current_tile():
				var targets = [target]
				_execute_effects(active_skill.get_effects(),targets)
				return true
	return false

func process_space_selection(tile,affected_tiles):
	if cell.is_tile_valid(tile) and not cell.is_tile_blocked(tile):
		var possible_targets = _get_possible_targets()
		var targets = _get_targets(affected_tiles,possible_targets)
		_execute_effects(active_skill.get_effects(),targets)
		return true
	return false

func process_empty_space_selection(tile):
	if active_skill.get_target() == GlobalVars.skill_target.SPACE:
		return _process_empty_space_skill(tile)

func process_skill_on_target(target):
	if viable_targets.find(target) != -1:
		viable_targets.clear()
		var targets = [target]
		_execute_effects(active_skill.get_effects(),targets)

func _process_empty_space_skill(tile):
	if cell.is_tile_available(tile):
		cell.clear_tile_left(cell.get_current_fighter_tile())
		var targets = [tile]
		_execute_effects(active_skill.get_effects(),targets)
		return true
	return false

func _process_self_skill(tile):
	var possible_targets = []
	var targets = []
	match active_skill.get_target():
		GlobalVars.skill_target.SELF:
			targets.append(cell.get_current_fighter())
		GlobalVars.skill_target.ALLIES_ALL:
			targets += cell.get_allies()
		GlobalVars.skill_target.ENEMIES_ALL:
			targets += cell.get_enemies()
		_:
			possible_targets += _get_possible_targets()
			var affected_tiles = cell.calculate_selection_tiles(tile,active_skill.get_area_value())
			targets = _get_targets(affected_tiles,possible_targets)
	_execute_effects(active_skill.get_effects(),targets)

func _on_skill_selected(skill):
	active_skill = skill
	var origin_tile = cell.get_current_fighter_tile()
	var skill_range = skill.get_range()
	match skill.get_selector():
		GlobalVars.skill_selector.SELF:
			_process_self_skill(origin_tile)
		GlobalVars.skill_selector.ENEMY:
			cell.set_actor_selection(origin_tile,active_skill.get_area_value())
			_highlight_viable_targets(origin_tile,cell.get_enemies(),skill_range)
		GlobalVars.skill_selector.ALLY:
			cell.set_actor_selection(origin_tile,active_skill.get_area_value())
			_highlight_viable_targets(origin_tile,cell.get_allies(),skill_range)
		GlobalVars.skill_selector.EMPTY_SPACE:
			cell.set_empty_space_selection()
		GlobalVars.skill_selector.SPACE:
			cell.set_space_selection(origin_tile,active_skill.get_area_value())

func _is_origin_self():
	if active_skill.selector_id == GlobalVars.skill_selector.SELF:
		return true
	return false

func _execute_effects(effects,targets = null):
	var caster = cell.get_current_fighter()
	for effect in effects:
		effect_methods.execute(effect,effect.get_method(),targets,caster)

func _highlight_viable_targets(origin_tile,party,skill_range):
	viable_targets.clear()
	for actor in party:
		var target_tile = actor.get_current_tile()
		if actor and skill_range != GlobalVars.skill_range.MELEE or (skill_range == GlobalVars.skill_range.MELEE and cell.is_target_in_melee_range(origin_tile,target_tile)):
			actor.toggle_light(true)
			viable_targets.append(actor)
		cell.set_canvas_module(true)

func _get_possible_targets():
	var targets = []
	match active_skill.get_target():
		GlobalVars.skill_target.ALLY:
			targets += cell.get_allies()
		GlobalVars.skill_target.ENEMY:
			targets += cell.get_enemies()
		GlobalVars.skill_target.ALL:
			targets += cell.get_everybody()
	return targets

func _get_targets(affected_tiles,possible_targets):
	var targets = []
	for target in possible_targets:
		if affected_tiles.find(target.get_current_tile()) != -1:
			targets.append(target)
	return targets
