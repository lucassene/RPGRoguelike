extends CenterContainer

var is_dragging = false

func _ready():
	EventHub.connect("skill_drag_started",self,"_on_skill_drag_started")
	EventHub.connect("skill_selected",self,"_on_skill_selected")
	EventHub.connect("skill_canceled",self,"_on_skill_canceled")
	EventHub.connect("battle_ended",self,"_on_battle_ended")

func _input(event):
	if is_dragging and event is InputEventScreenTouch and not event.is_pressed():
		is_dragging = false
		var global_touch_pos = get_canvas_transform().xform_inv(event.position)
		if _is_on_button(global_touch_pos):
			EventHub.emit_signal("skill_canceled")
			hide()

func _is_on_button(touch_pos):
	if touch_pos.x < rect_global_position.x or touch_pos.x > (rect_global_position.x + rect_size.x):
		return false
	if touch_pos.y < rect_global_position.y or touch_pos.y > (rect_global_position.y + rect_size.y):
		return false
	return true

func _on_skill_drag_started(_position,_preview,_skill):
	is_dragging = true
	show()

func _on_skill_selected(_skill):
	is_dragging = false
	show()

func _on_battle_ended():
	hide()

func _on_skill_canceled():
	hide()

func _on_TextureButton_pressed():
	EventHub.emit_signal("skill_canceled")
	hide()
