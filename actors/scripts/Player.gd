extends Actor

func fade_out():
	tween.interpolate_property(self,"modulate:a",1.0,0.0,0.5,Tween.TRANS_LINEAR,Tween.EASE_OUT)
	tween.start()

func spawn(spawn_position):
	.spawn(spawn_position)
	tween.interpolate_property(self,"modulate:a",0.0,1.0,0.5,Tween.TRANS_LINEAR,Tween.EASE_OUT)
	tween.start()
	

