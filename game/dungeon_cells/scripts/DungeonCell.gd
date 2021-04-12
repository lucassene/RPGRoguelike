extends TileMap
class_name DungeonCell

onready var enemy_data = preload("res://database/EnemyData.gd").new()
onready var enemy_scene = preload("res://actors/scenes/Enemy.tscn")
onready var npc_scene = preload("res://actors/scenes/NPC.tscn")

onready var waypoint_container = $Waypoints
onready var npc_container = $NPCs
onready var cell_hud = $CanvasLayer/CellHUD
onready var overlay_map: TileMap = $OverlayMap

export(Vector2) var begin = Vector2(1,2)
export(Vector2) var end = Vector2(8,12)
export(Vector2) var hero_spawn_begin = Vector2(2,8)
export(Vector2) var hero_spawn_end = Vector2(6,10)
export(Vector2) var enemy_spawn_begin = Vector2(2,3)
export(Vector2) var enemy_spawn_end = Vector2(6,5)
export(Vector2) var npc_spawn = Vector2(4,4)

const NORTH_NEIGHBOR = Vector2(0,-1)
const WEST_NEIGHBOR = Vector2(-1,0)
const EAST_NEIGHBOR = Vector2(1,0)
const SOUTH_NEIGHBOR = Vector2(0,1)
enum {TILE_OK,TILE_BLOCKED}
enum {EMPTY,ALLY,ENEMY,NPC,ITEM}

var dungeon
var exits = [] setget ,get_exits
var tile_list = []
var cell_type setget set_type,get_type
var cell_data
var tile_taken = []
var enemy_party = []
var player_party = []
var npc
var highlighted_tiles = []

func get_exits():
	return exits

func set_type(value):
	cell_type = value

func get_type():
	return cell_type

func _ready():
	randomize()
	hide_hud()
	for waypoint in waypoint_container.get_children():
		exits.append(waypoint.get_direction())

func initialize(_dungeon,data,type):
	dungeon = _dungeon
	enemy_data.initialize()
	cell_data = data
	cell_hud.set_cell_label(cell_data.get_cell_type_desc(type))
	tile_taken.clear()
	set_type(type)
	_populate_cell()

func hide_hud():
	cell_hud.hide()

func initialize_hud():
	cell_hud.show()

func get_exit_position(direction):
	for waypoint in waypoint_container.get_children():
		if waypoint.get_direction() == direction:
			var wp_coords = waypoint.get_coords()
			return map_to_world(wp_coords)
	return Vector2.ZERO

func get_hero_spawn():
	var spawn_range = [hero_spawn_begin,hero_spawn_end]
	var spawn_point = _get_random_spawn(spawn_range)
	return spawn_point

func add_hero(hero):
	player_party.append(hero)

func get_cell_size():
	var cell_size = get_used_rect().end
	cell_size.x *= GlobalVars.CELL_SIZE.x
	cell_size.y *= GlobalVars.CELL_SIZE.y
	return cell_size

func get_actor_spawn_position(spawn_tile):
	return map_to_world(spawn_tile)

func calculate_movement(tile,speed,move_type):
	match move_type:
		GlobalVars.movement_type.REGULAR:
			_calculate_regular_movement(tile,speed)
		GlobalVars.movement_type.TOWER:
			_calculate_tower_movement(tile,speed)

func remove_from_taken(tile):
	tile_taken.erase(tile)

func _calculate_regular_movement(_tile,speed):
	var movement = []
	var to_check = [{tile = _tile,value = 0}]
	var checked_tiles = []
	for t in to_check:
		if checked_tiles.find(t.tile) == -1:
			for n in _get_neighbors(t.tile):
				var nt ={tile = n,value = t.value + 1}
				if _can_move(n):
					movement.append(nt.tile)
					if nt.value < speed:
						to_check.append(nt)
			checked_tiles.append(t.tile)
	_update_highlighted_cells(movement)
	return movement

func _get_neighbors(tile):
	var neighbors = []
	neighbors.append(tile + NORTH_NEIGHBOR)
	neighbors.append(tile + WEST_NEIGHBOR)
	neighbors.append(tile + EAST_NEIGHBOR)
	neighbors.append(tile + SOUTH_NEIGHBOR)
	return neighbors

func _calculate_tower_movement(tile,speed):
	var movement = []
	movement += _check_tiles_in_one_direction(tile,speed,NORTH_NEIGHBOR)
	movement += _check_tiles_in_one_direction(tile,speed,WEST_NEIGHBOR)
	movement += _check_tiles_in_one_direction(tile,speed,EAST_NEIGHBOR)
	movement += _check_tiles_in_one_direction(tile,speed,SOUTH_NEIGHBOR)
	_update_highlighted_cells(movement)
	return movement

func _check_tiles_in_one_direction(tile,speed,direction):
	var neighbors = []
	for i in range(1,speed + 1):
		var neighbor = tile - (direction * i)
		if _can_move(neighbor):
			neighbors.append(neighbor)
		else: break
	return neighbors

func _can_move(tile):
	if not _is_tile_blocked(get_cellv(tile)) and not _is_tile_taken(tile):
		overlay_map.set_cell(tile.x,tile.y,TILE_OK)
		return true
	elif _is_tile_taken(tile):
		return false
		#overlay_map.set_cell(tile.x,tile.y,TILE_BLOCKED)
	return false

func _update_highlighted_cells(movement):
	highlighted_tiles.clear()
	highlighted_tiles += movement

func _populate_cell():
	var npcs_needed = cell_data.get_npcs_needed(cell_type)
	match npcs_needed:
		GlobalVars.actor_type.ENEMY:
			_instance_enemies()
		GlobalVars.actor_type.NPC:
			_instance_npc()
		GlobalVars.actor_type.ENEMY_NPC:
			_instance_enemies()
			_instance_npc()

func _instance_enemies():
	var enemy_count = _get_enemy_count()
	var enemies = enemy_data.get_enemies()
	var random
	var enemy
	for _x in range(enemy_count):
		random = randi() % enemies.size()
		enemy = enemy_scene.instance()
		npc_container.add_child(enemy)
		enemy.initialize(enemies[random],self)
		enemy_party.append(enemy)
		_spawn_enemy(enemy)

func _instance_npc():
	var new_npc = npc_scene.instance()
	npc_container.add_child(new_npc)
	_spawn_npc(new_npc)
	npc = new_npc

func _get_actor_tile_spawn(actor_type):
	var spawn_range = PoolVector2Array()
	var spawn_point = Vector2.ZERO
	if actor_type == GlobalVars.actor_type.ENEMY:
		spawn_range = [enemy_spawn_begin,enemy_spawn_end]
		spawn_point = _get_random_spawn(spawn_range)
	else:
		spawn_range = [npc_spawn,npc_spawn]
		spawn_point = npc_spawn
		tile_taken.append(npc_spawn)
	return spawn_point

func _get_random_spawn(spawn_range):
	var spawn = Vector2.ZERO
	while spawn == Vector2.ZERO:
		var x_factor = int(spawn_range[1].x - spawn_range[0].x) + 1
		var y_factor = int(spawn_range[1].y - spawn_range[0].y) + 1
		var rand_x = randi() % x_factor + int(spawn_range[0].x)
		var rand_y = randi() % y_factor + int(spawn_range[0].y)
		var tile_id = get_cellv(Vector2(rand_x,rand_y))
		if not _is_tile_blocked(tile_id) and tile_taken.find(Vector2(rand_x,rand_y)) == -1:
			spawn = Vector2(rand_x,rand_y)
			tile_taken.append(Vector2(rand_x,rand_y))
	return spawn

func _spawn_enemy(enemy):
	var spawn_tile = _get_actor_tile_spawn(GlobalVars.actor_type.ENEMY)
	var spawn_position = get_actor_spawn_position(spawn_tile)
	enemy.spawn(spawn_tile,spawn_position)

func _spawn_npc(new_npc):
	var spawn_tile = _get_actor_tile_spawn(GlobalVars.actor_type.NPC)
	var spawn_position = get_actor_spawn_position(spawn_tile)
	new_npc.spawn(spawn_tile,spawn_position)

func _clear_npcs():
	enemy_party.clear()
	if npc_container.get_child_count() > 0:
		for actor in npc_container.get_children():
			actor.queue_free()

func _tile_action(_tile):
	pass

func _get_tile_content(tile):
	if tile_taken.find(tile) == -1:
		return EMPTY

func _get_enemy_count():
	return randi() % 3 + 1

func _is_tile_blocked(tile):
	return false if tile == 0 else true

func _is_tile_taken(tile):
	if tile_taken.find(tile) != -1:
		return true
	return false
