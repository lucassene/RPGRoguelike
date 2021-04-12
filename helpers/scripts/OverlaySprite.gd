extends Sprite

onready var overlay_ok = preload("res://assets/textures/overlay-ok.png")
onready var overlay_warn = preload("res://assets/textures/overlay-warn.png")

enum {OK,WARN}

func show_overlay(type):
	match type:
		OK:
			texture = overlay_ok
		WARN:
			texture = overlay_warn
	visible = true

