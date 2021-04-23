extends TextureProgress

onready var tween: Tween = $Tween

var max_health
var current_health
var healthy_tint = Color(0.0,1.0,0.0,1.0)

func initialize(health):
	max_health = health
	max_value = max_health
	current_health = max_health
	value = current_health
	tint_progress = healthy_tint

func update_bar(damage):
	current_health = max(0,current_health - damage)
	_set_tint_tween(current_health)
	tween.interpolate_property(self,"value",value,current_health,0.25,Tween.TRANS_LINEAR,Tween.EASE_OUT)
	tween.start()

func _set_tint_tween(new_value):
	var portion = float(new_value) / float(max_health)
	var new_tint
	if portion >= 0.75:
		new_tint = min((100 - portion*100) * 0.02,0.5)
		tween.interpolate_property(self,"tint_progress:r",tint_progress.r,new_tint,0.25,Tween.TRANS_LINEAR,Tween.EASE_OUT)
		tween.interpolate_property(self,"tint_progress:g",tint_progress.r,1.0,0.25,Tween.TRANS_LINEAR,Tween.EASE_OUT)
	elif portion >= 0.5:
		new_tint = max((100 - portion*100) * 0.02,1.0)
		tween.interpolate_property(self,"tint_progress:r",tint_progress.r,new_tint,0.25,Tween.TRANS_LINEAR,Tween.EASE_OUT)
	else:
		new_tint = max(0.0,(portion*100) / 50)
		tween.interpolate_property(self,"tint_progress:r",tint_progress.r,1.0,0.25,Tween.TRANS_LINEAR,Tween.EASE_OUT)
		tween.interpolate_property(self,"tint_progress:g",tint_progress.g,new_tint,0.25,Tween.TRANS_LINEAR,Tween.EASE_OUT)
