extends CenterContainer

func _on_TextureButton_pressed():
	EventHub.emit_signal("skill_canceled")
