extends TileMap

onready var waypoint_container = $Waypoints

export(Vector2) var begin = Vector2(1,2)
export(Vector2) var end = Vector2(8,12)

var aStar = AStar2D.new()
var exits = [] setget ,get_exits
var tile_list = []

func get_exits():
	return exits

func get_exit_position(direction):
	for waypoint in waypoint_container.get_children():
		if waypoint.get_direction() == direction:
			return waypoint.get_coords()
	return null

func get_actor_path(actor,target):
	var actor_tile = world_to_map(actor.position)
	var origin_index = tile_list.find(actor_tile)
	print(origin_index)
	var target_index = tile_list.find(target)
	print(target_index)
	var path = aStar.get_point_path(origin_index,target_index)
	print(path)
	return path

#func _input(event):
#	if event is InputEventMouseButton:
#		var cell = get_cellv(world_to_map(event.position))

func _ready():
	for waypoint in waypoint_container.get_children():
		exits.append(waypoint.get_direction())
	_set_aStar_navigation()

func _set_aStar_navigation():
	aStar.clear()
	tile_list.clear()
	var index = 0
	for y in range(begin.y,end.y):
		for x in range(begin.x,end.x):
			var tile_pos = Vector2(x,y)
			var tile = get_cellv(tile_pos)
			var tile_world_pos = map_to_world(tile_pos)
			aStar.add_point(index,tile_world_pos)
			tile_list.insert(index,tile_pos)
			if _is_tile_blocked(tile):
				aStar.set_point_disabled(index)
			index += 1
	for item in aStar.get_points():
		_connect_point(item)

func _connect_point(index):
	var coords = tile_list[index]
	var to_connect = []
	var neighbor_coord = Vector2.ZERO
	if coords.y > begin.y:
		neighbor_coord = Vector2(coords.x,coords.y - 1)
		_add_to_list(neighbor_coord,to_connect)
	if coords.y < end.y:
		neighbor_coord = Vector2(coords.x,coords.y + 1)
		_add_to_list(neighbor_coord,to_connect)
	if coords.x > begin.x:
		neighbor_coord = Vector2(coords.x - 1,coords.y)
		_add_to_list(neighbor_coord,to_connect)
	if coords.x < end.x:
		neighbor_coord = Vector2(coords.x + 1,coords.y)
		_add_to_list(neighbor_coord,to_connect)
	for id in to_connect:
		aStar.connect_points(index,id)

func _add_to_list(coord,list):
	var to_add = tile_list.find(coord)
	if to_add != -1:
		list.append(to_add)

func _is_tile_blocked(tile):
	return false if tile == 0 else true
