extends Node2D
tool

export(Vector2) var tile_coord
export(GlobalVars.direction) var direction setget ,get_direction

func get_direction():
	return direction
	
func get_coords():
	return tile_coord

func _process(_delta):
	if Engine.editor_hint:
		$Sprite.visible = true
		match direction:
			GlobalVars.direction.NORTH:
				$Sprite.rotation_degrees = 0
			GlobalVars.direction.WEST:
				$Sprite.rotation_degrees = -90
			GlobalVars.direction.EAST:
				$Sprite.rotation_degrees = 90

