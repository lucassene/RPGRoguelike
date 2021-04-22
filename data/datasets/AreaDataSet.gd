extends Resource

var id: int
var desc: String
var value: int setget ,get_value

func get_value():
	return value

func _init(area):
	id = area.ID
	desc = area.desc
	value = area.value

