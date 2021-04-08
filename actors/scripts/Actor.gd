extends KinematicBody2D
class_name Actor

var path = []

func move_to(_path):
	path = _path

func _physics_process(_delta):
	while path.size() > 0:
		global_position = path[0]
		path.remove(0)
		yield(get_tree().create_timer(0.5),"timeout")

