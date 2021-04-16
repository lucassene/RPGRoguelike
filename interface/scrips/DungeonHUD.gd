extends Control

onready var navigation_menu = $VBoxContainer/BottomContainer/NavigationMenu
onready var skill_menu = $VBoxContainer/BottomContainer/SkillMenu
onready var cell_label = $VBoxContainer/TopContainer/TopLabelContainer/CellName
onready var turn_label = $VBoxContainer/TopContainer/TopLabelContainer/TurnLabel
onready var ready_label = $VBoxContainer/MiddleContainer/VBoxContainer/ReadyLabel
onready var cancel_button = $VBoxContainer/BottomContainer/CancelButton

enum {EXPLORATION,BATTLE,SHOP,REST}

const TURN_TEMPLATE = "%s's turn"

var cell_repo
var cell_type
var mode

func _ready():
	EventHub.connect("turn_changed",self,"_on_battle_turn_changed")
	EventHub.connect("battle_ended",self,"_on_battle_ended")
	EventHub.connect("skill_selected",self,"_on_skill_selected")
	EventHub.connect("skill_canceled",self,"_on_skill_canceled")
	EventHub.connect("skill_executed",self,"_on_skill_executed")

func initialize(data):
	cell_repo = data
	navigation_menu.initialize(cell_repo)

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
	turn_label.show()
	turn_label.text = TURN_TEMPLATE % actor_name
	if is_enemy:
		skill_menu.clear_skills_menu()

func _on_battle_ended():
	turn_label.hide()
	skill_menu.clear_skills_menu()
	skill_menu.hide()
	_begin_exploration_mode()

func _on_skill_selected(_skill):
	skill_menu.hide()
	cancel_button.show()

func _on_skill_canceled():
	cancel_button.hide()
	skill_menu.show()

func _on_skill_executed():
	cancel_button.hide()
