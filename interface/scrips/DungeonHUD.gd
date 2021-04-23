extends Control

onready var navigation_menu = $VBoxContainer/BottomContainer/NavigationMenu
onready var skill_menu = $VBoxContainer/BottomContainer/SkillMenu
onready var cell_label = $VBoxContainer/TopContainer/TopLabelContainer/CellName
onready var turn_label = $VBoxContainer/TopContainer/TopLabelContainer/TurnLabel
onready var ready_label = $VBoxContainer/MiddleContainer/VBoxContainer/ReadyLabel
onready var cancel_button = $VBoxContainer/TopContainer/CancelButton
onready var hold_feedback: TextureProgress = $HoldFeedback
onready var tween: Tween = $Tween

enum {EXPLORATION,BATTLE,SHOP,REST}

const TURN_TEMPLATE = "%s's turn"

var cell_repo
var cell_type
var mode
var drag_preview
var is_dragging = false
var touch_position

func _ready():
	EventHub.connect("turn_changed",self,"_on_battle_turn_changed")
	EventHub.connect("battle_ended",self,"_on_battle_ended")
	EventHub.connect("skill_drag_started",self,"_on_skill_drag_started")
	EventHub.connect("skill_clicked",self,"_on_skill_clicked")

func _physics_process(_delta):
	if is_dragging and drag_preview and touch_position:
		drag_preview.rect_global_position = touch_position
	if hold_feedback.visible == true and touch_position:
		hold_feedback.rect_global_position = touch_position

func _input(event):
	get_viewport().unhandled_input(event)
	if event is InputEventScreenTouch:
		if event.is_pressed():
			touch_position = get_canvas_transform().xform_inv(event.position)
		elif is_dragging:
			touch_position = null
			is_dragging = false
			drag_preview.queue_free()
	if event is InputEventScreenDrag and (is_dragging or hold_feedback.visible == true):
		touch_position = get_canvas_transform().xform_inv(event.position)

func initialize():
	cell_repo = RepoHub.get_cell_repo()
	navigation_menu.initialize()

func update_hud(_cell_type):
	cell_type = _cell_type
	cell_label.text = cell_repo.get_cell_type_desc(cell_type)
	_set_hud_mode()

func _set_hud_mode():
	mode = cell_repo.get_cell_group(cell_type)
	match mode:
		BATTLE:
			_begin_battle_mode()
		SHOP:
			_begin_shop_mode()
		REST:
			_begin_rest_mode()

func _begin_battle_mode():
	navigation_menu.hide()
	ready_label.show()
	yield(get_tree().create_timer(2.0),"timeout")
	ready_label.hide()
	EventHub.emit_signal("start_battle")

func _begin_shop_mode():
	navigation_menu.show()
	EventHub.emit_signal("start_shop")

func _begin_rest_mode():
	navigation_menu.show()
	EventHub.emit_signal("start_rest")

func _begin_exploration_mode():
	navigation_menu.show()

func set_exits(exits):
	navigation_menu.update_menu(exits)

func _on_battle_turn_changed(actor_name,is_enemy):
	cancel_button.hide()
	turn_label.show()
	turn_label.text = TURN_TEMPLATE % actor_name
	if is_enemy:
		skill_menu.clear_skills_menu()

func _on_battle_ended():
	turn_label.hide()
	skill_menu.clear_skills_menu()
	skill_menu.hide()
	_begin_exploration_mode()

func _on_skill_drag_started(button_position,preview,_skill):
	hold_feedback.visible = false
	drag_preview = preview
	add_child(drag_preview)
	drag_preview.rect_global_position = button_position
	is_dragging = true

func _on_skill_clicked(value):
	hold_feedback.visible = value
	if value:
		tween.interpolate_property(hold_feedback,"value",0.0,1.0,1.0,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
		tween.start()
