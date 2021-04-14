extends KinematicBody2D
class_name Actor

onready var tween: Tween = $Tween
onready var turn_mark: Sprite = $TurnMark
onready var hover_light: Light2D = $HoverLight
onready var damage_label: Label = $DmgLabel

signal destination_reached
signal movement_started
signal actor_killed

const HEAL_COLOR = Color(0.3,0.93,0.21,1.0)
const DAMAGE_COLOR = Color(0.95,0.24,0.24,1.0)
const DAMAGE_INDICATOR_OFFSET = 64.0
const PROXIMITY_THRESHOLD = 3.0
export(float) var SPEED = 3.0
export(GlobalVars.actor_type) var type = GlobalVars.actor_type.PLAYER

var actor_dataset
var actor_repo
var effect_repo
var skill_repo
var current_target = Vector2.ZERO
var allowed_movement = PoolVector2Array()
var current_tile = Vector2.ZERO setget ,get_current_tile
var parent_cell setget set_parent_cell
var in_battle = false

func get_actor_name():
	return actor_dataset.get_name()
	
func get_current_tile():
	return current_tile

func set_parent_cell(value):
	parent_cell = value

func _physics_process(delta):
	_move(delta)

func initialize(_actor_repo,_skill_repo,_effect_repo,_actor,cell):
	actor_repo = _actor_repo
	effect_repo = _effect_repo
	skill_repo = _skill_repo
	parent_cell = cell

func move_to(tile,target):
	parent_cell.remove_from_taken(current_tile)
	current_tile = tile
	current_target = target
	emit_signal("movement_started")

func spawn(spawn_tile,spawn_position):
	current_tile = spawn_tile
	global_position = spawn_position

func begin_turn():
	turn_mark.show()
	in_battle = true

func end_turn():
	turn_mark.hide()
	in_battle = false

func toggle_light(value):
	hover_light.visible = value

func get_stat(stat):
	return actor_dataset.get_stat(stat)

func apply_damage(value):
	var damage = actor_dataset.apply_damage(value)
	print(actor_dataset.get_name()," suffered ",damage," damage.")
	_show_damage_indicator(damage)
	if actor_dataset.is_dead(): emit_signal("actor_killed",self)

func modify_defense(value):
	var new_defense = actor_dataset.modify_defense(value)
	print(actor_dataset.get_name()," now has ",new_defense," defense.")

func teleport_to(tile):
	global_position = parent_cell.map_to_world(tile)
	parent_cell.remove_from_taken(current_tile)
	current_tile = tile

func _show_damage_indicator(value):
	if value > 0:
		damage_label.text = "-%s" % abs(value)
		damage_label.add_color_override("font_color",DAMAGE_COLOR)
	else:
		damage_label.text = "+%s" % abs(value)
		damage_label.add_color_override("font_color",HEAL_COLOR)
	tween.interpolate_property(damage_label,"rect_position:y",damage_label.rect_position.y,damage_label.rect_position.y - DAMAGE_INDICATOR_OFFSET,0.5,Tween.TRANS_LINEAR,Tween.EASE_IN)
	tween.interpolate_property(damage_label,"modulate:a",1.0,0.0,0.5,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
	tween.start()

func _move(delta):
	if current_target != Vector2.ZERO:
		global_position = global_position.linear_interpolate(current_target,delta*SPEED)
		if _has_arrived():
			current_target = Vector2.ZERO
			emit_signal("destination_reached")

func _has_arrived():
	if global_position.distance_to(current_target) < PROXIMITY_THRESHOLD:
		global_position = current_target
		return true
	return false

func _on_Area2D_input_event(_viewport, event, _shape_idx):
	if event is InputEventScreenTouch and event.is_pressed():
		EventHub.emit_signal("actor_selected",self)

func _on_Tween_tween_completed(object, _key):
	if object == damage_label:
		damage_label.rect_position = Vector2.ZERO
		if actor_dataset.is_dead(): queue_free()
