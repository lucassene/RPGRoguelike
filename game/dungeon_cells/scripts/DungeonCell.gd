extends TileMap
class_name DungeonCell

onready var enemy_scene = preload("res://actors/scenes/Enemy.tscn")
onready var npc_scene = preload("res://actors/scenes/NPC.tscn")
onready var skill_handler = $SkillHandler
onready var waypoint_container = $Waypoints
onready var npc_container = $NPCs
onready var overlay_map: TileMap = $OverlayMap
onready var fog_map: TileMap = $FogMap
onready var canvas_modulate: CanvasModulate = $CanvasModulate
onready var tile_light: Light2D = $TileLight

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
const NORTH_EAST_NEIGHBOR = Vector2(-1,1)
const SOUTH_EAST_NEIGHBOR = Vector2(1,1)
const SOUTH_WEST_NEIGHBOR = Vector2(1,-1)
const NORTH_WEST_NEIGHBOR = Vector2(-1,-1)
const MOVE_NEIGHBORS = [NORTH_NEIGHBOR,EAST_NEIGHBOR,SOUTH_NEIGHBOR,WEST_NEIGHBOR]
const TARGET_NEIGHBORS = [NORTH_NEIGHBOR,NORTH_EAST_NEIGHBOR,EAST_NEIGHBOR,SOUTH_EAST_NEIGHBOR,SOUTH_NEIGHBOR,SOUTH_WEST_NEIGHBOR,WEST_NEIGHBOR,NORTH_WEST_NEIGHBOR]

enum {TILE_OK,TILE_BLOCKED}
enum {EMPTY,ALLY,ENEMY,NPC,ITEM}
enum {NORMAL,ACTOR_SELECTION,EMPTY_SPACE_SELECTION,SPACE_SELECTION}

var enemy_repo
var effect_repo

var dungeon
var exits = [] setget ,get_exits
var tile_list = []
var cell_type setget set_type,get_type
var cell_repo
var skill_repo
var taken_tiles = {}
var enemy_party = [] setget ,get_enemies
var player_party = [] setget ,get_allies
var npc
var in_battle = false
var cell_mode = NORMAL

func get_exits():
	return exits

func set_type(value):
	cell_type = value

func get_type():
	return cell_type

func get_enemies():
	return enemy_party

func get_allies():
	return player_party

func get_everybody():
	return player_party + enemy_party

func _ready():
	randomize()
	_load_repositories()
	for waypoint in waypoint_container.get_children():
		exits.append(waypoint.get_direction())

func _load_repositories():
	cell_repo = RepoHub.get_cell_repo()
	skill_repo = RepoHub.get_skill_repo()
	enemy_repo = RepoHub.get_enemy_repo()
	effect_repo = RepoHub.get_effect_repo()
	
func initialize(_dungeon,type):
	dungeon = _dungeon
	taken_tiles.clear()
	set_type(type)
	_populate_cell()

func is_in_battle():
	return in_battle

func get_exit_position(direction):
	for waypoint in waypoint_container.get_children():
		if waypoint.get_direction() == direction:
			var wp_coords = waypoint.get_coords()
			return [wp_coords,map_to_world(wp_coords)]
	return null

func get_hero_spawn(hero):
	var spawn_range = [hero_spawn_begin,hero_spawn_end]
	var spawn_point = _get_random_spawn(spawn_range)
	_take_tile(hero,spawn_point)
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

func change_actor_tile(actor,to_remove,to_take = null):
	taken_tiles.erase(to_remove)
	if to_take:
		taken_tiles[to_take] = actor

func get_tile_content(tile):
	return taken_tiles.get(tile)

func is_tile_blocked(tile):
	return false if get_cellv(tile) == 0 else true

func is_tile_taken(tile):
	if taken_tiles.get(tile) != null:
		return true
	return false

func is_tile_available(tile):
	if not is_tile_taken(tile) and not is_tile_blocked(tile):
		return true
	return false

func is_tile_valid(tile):
	if tile.x < begin.x or tile.x > end.x:
		return false
	if tile.y < begin.y or tile.y > end.y:
		return false
	return true

func _take_tile(hero,tile):
	taken_tiles[tile] = hero

func _populate_cell():
	var npcs_needed = cell_repo.get_npcs_needed(cell_type)
	match npcs_needed:
		GlobalVars.actor_type.ENEMY:
			_instance_enemies()
		GlobalVars.actor_type.NPC:
			_instance_npc()
		GlobalVars.actor_type.ENEMY_NPC:
			_instance_npc()
			_instance_enemies()

func _instance_enemies():
	var enemy_count = _get_enemy_count()
	var enemies = enemy_repo.get_enemies()
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

func _get_actor_tile_spawn(actor,actor_type):
	var spawn_range = PoolVector2Array()
	var spawn_point = Vector2.ZERO
	if actor_type == GlobalVars.actor_type.ENEMY:
		spawn_range = [enemy_spawn_begin,enemy_spawn_end]
		spawn_point = _get_random_spawn(spawn_range)
	else:
		spawn_range = [npc_spawn,npc_spawn]
		spawn_point = npc_spawn
		taken_tiles[spawn_point] = actor
	return spawn_point

func _get_random_spawn(spawn_range):
	var spawn = Vector2.ZERO
	while spawn == Vector2.ZERO:
		var x_factor = int(spawn_range[1].x - spawn_range[0].x) + 1
		var y_factor = int(spawn_range[1].y - spawn_range[0].y) + 1
		var rand_x = randi() % x_factor + int(spawn_range[0].x)
		var rand_y = randi() % y_factor + int(spawn_range[0].y)
		var tile = Vector2(rand_x,rand_y)
		if is_tile_available(tile):
			spawn = tile
	return spawn

func _spawn_enemy(enemy):
	var spawn_tile = _get_actor_tile_spawn(enemy,GlobalVars.actor_type.ENEMY)
	taken_tiles[spawn_tile] = enemy
	var spawn_position = get_actor_spawn_position(spawn_tile)
	enemy.spawn(spawn_tile,spawn_position)

func _spawn_npc(new_npc):
	var spawn_tile = _get_actor_tile_spawn(new_npc,GlobalVars.actor_type.NPC)
	taken_tiles[spawn_tile] = new_npc
	var spawn_position = get_actor_spawn_position(spawn_tile)
	new_npc.spawn(spawn_tile,spawn_position)

func _clear_npcs():
	enemy_party.clear()
	if npc_container.get_child_count() > 0:
		for actor in npc_container.get_children():
			actor.queue_free()

func _tile_action(_tile):
	pass

func _get_enemy_count():
	return randi() % 3 + 2
