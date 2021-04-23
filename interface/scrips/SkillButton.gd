extends CenterContainer

onready var name_label: Label = $Button/NameLabel
onready var button = $Button
onready var texture = $SkillTexture
onready var preview_name = $SkillTexture/PreviewName

const TOUCH_OFFSET = 20

var skill
var time = 0
var button_clicked = false
var is_dragging = false
var begin_touch_pos

func _physics_process(delta):
	if button_clicked:
		time += delta
		if time > 1:
			button_clicked = false
			_set_drag(true)
			_create_preview()

func _input(event):
	if button_clicked and event is InputEventScreenDrag:
		var global_touch_pos = get_canvas_transform().xform_inv(event.position)
		if begin_touch_pos == null:
			begin_touch_pos = global_touch_pos
		elif _has_moved(global_touch_pos):
			button_clicked = false
			EventHub.emit_signal("skill_clicked",false)
			_set_drag(false)
			
func set_data(data):
	skill = data
	name_label.text = skill.name
	preview_name.text = skill.name

func _has_moved(new_touch_pos):
	if begin_touch_pos.distance_to(new_touch_pos) > TOUCH_OFFSET:
		return true
	return false

func _create_preview():
	var preview = texture.duplicate()
	preview.show()
	EventHub.emit_signal("skill_drag_started",rect_global_position,preview,skill)

func _set_drag(value):
	is_dragging = value
	if value == false:
		time = 0
		begin_touch_pos = null

func _on_Button_button_down():
	button_clicked = true
	EventHub.emit_signal("skill_clicked",true)

func _on_Button_pressed():
	if not is_dragging:
		EventHub.emit_signal("skill_selected",skill)

func _on_Button_button_up():
	button_clicked = false
	EventHub.emit_signal("skill_clicked",false)
	_set_drag(false)
