extends CenterContainer

func can_drop_data(_position, _data):
	return true

func drop_data(_position, _data):
	EventHub.emit_signal("skill_canceled")

func _on_TextureButton_pressed():
	EventHub.emit_signal("skill_canceled")
