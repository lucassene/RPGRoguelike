extends TileMap

onready var enemy_scene = preload("res://actors/scenes/Enemy.tscn")
onready var npc_scene = preload("res://actors/scenes/NPC.tscn")

onready var waypoint_container = $Waypoints
onready var npc_container = $NPCs

export(Vector2) var begin = Vector2(1,2)
export(Vector2) var end = Vector2(8,12)
export(Vector2) var player_spawn_begin = Vector2(2,8)
export(Vector2) var player_spawn_end = Vector2(6,10)
export(Vector2) var enemy_spawn_begin = Vector2(2,3)
export(Vector2) var enemy_spawn_end = Vector2(6,5)
export(Vector2) var npc_spawn = Vector2(4,4)

var exits = [] setget ,get_exits
var tile_list = []
var cell_type setget set_type,get_type
var cell_data
var spawn_taken = []
var enemy_party = []
var npc

func get_exits():
	return exits

func set_type(value):
	cell_type = value

func get_type():
	return cell_type

func _ready():
	randomize()
	for waypoint in waypoint_container.get_children():
		exits.append(waypoint.get_direction())

#Debug
func _input(event):
	if event.is_action_pressed("debug"):
		var enemy = enemy_party[0]
		enemy_party.remove(0)
		enemy.queue_free()

func initialize(data,type):
	cell_data = data
	spawn_taken.clear()
	set_type(type)
	_populate_cell()

func get_exit_position(direction):
	for waypoint in waypoint_container.get_children():
		if waypoint.get_direction() == direction:
			var wp_coords = waypoint.get_coords()
			return map_to_world(wp_coords)
	return Vector2.ZERO

func get_player_spawn():
	var spawn_range = [player_spawn_begin,player_spawn_end]
	var spawn_point = _get_random_spawn(spawn_range)
	return map_to_world(spawn_point)

func get_cell_size():
	var cell_size = get_used_rect().end
	cell_size.x *= GlobalVars.CELL_SIZE.x
	cell_size.y *= GlobalVars.CELL_SIZE.y
	return cell_size

func _populate_cell():
	var npcs_needed = cell_data.get_npcs_needed(cell_type)
	match npcs_needed:
		GlobalVars.ENEMY:
			_instance_enemies()
		GlobalVars.NPC:
			_instance_npc()
		GlobalVars.ENEMY_NPC:
			_instance_enemies()
			_instance_npc()

func _instance_enemies():
	var enemy_count = _get_enemy_count()
	var enemy
	for _x in range(enemy_count):
		enemy = enemy_scene.instance()
		npc_container.add_child(enemy)
		enemy_party.append(enemy)
		_spawn_enemy(enemy)

func _instance_npc():
	var new_npc = npc_scene.instance()
	npc_container.add_child(new_npc)
	_spawn_npc(new_npc)
	npc = new_npc

func _get_actor_spawn(actor_type):
	var spawn_range = PoolVector2Array()
	var spawn_point = Vector2.ZERO
	if actor_type == GlobalVars.ENEMY:
		spawn_range = [enemy_spawn_begin,enemy_spawn_end]
		spawn_point = _get_random_spawn(spawn_range)
	else:
		spawn_range = [npc_spawn,npc_spawn]
		spawn_point = npc_spawn
		spawn_taken.append(npc_spawn)
	return map_to_world(spawn_point)

func _get_random_spawn(spawn_range):
	var spawn = Vector2.ZERO
	while spawn == Vector2.ZERO:
		var x_factor = int(spawn_range[1].x - spawn_range[0].x) + 1
		var y_factor = int(spawn_range[1].y - spawn_range[0].y) + 1
		var rand_x = randi() % x_factor + int(spawn_range[0].x)
		var rand_y = randi() % y_factor + int(spawn_range[0].y)
		var tile_id = get_cellv(Vector2(rand_x,rand_y))
		if not _is_tile_blocked(tile_id) and spawn_taken.find(Vector2(rand_x,rand_y)) == -1:
			spawn = Vector2(rand_x,rand_y)
			spawn_taken.append(Vector2(rand_x,rand_y))
	return spawn

func _spawn_enemy(enemy):
	var spawn_position = _get_actor_spawn(GlobalVars.ENEMY)
	enemy.spawn(spawn_position)

func _spawn_npc(new_npc):
	var spawn_position = _get_actor_spawn(GlobalVars.NPC)
	new_npc.spawn(spawn_position)

func _clear_npcs():
	enemy_party.clear()
	if npc_container.get_child_count() > 0:
		for actor in npc_container.get_children():
			actor.queue_free()

func _get_enemy_count():
	return randi() % 3 + 1

#func _input(event):
#	if event is InputEventMouseButton:
#		var cell = get_cellv(world_to_map(event.position))

func _is_tile_blocked(tile):
	return false if tile == 0 else true
