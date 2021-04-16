extends Node

const SQLite = preload("res://addons/godot-sqlite/bin/gdsqlite.gdns")

var database
var last_query = ""

func _ready():
	_load_database()
	database.open_db()

func query(string):
	print(string)
	last_query = string
	database.query(string)
	var result = database.query_result
	return result.duplicate()

func insert(table,data):
	database.insert_row(table,data)

func _load_database():
	database = SQLite.new()
	database.path = _get_db_path()

func _get_db_path():
	var dir = "res://data/database/game_database"
	if OS.get_name() == "Android" or OS.get_name() == "iOS":
		dir = "user://data/database/game_database"
		_copy_data_to_user()
	return dir

func _copy_data_to_user():
	var data_path = "res://data/database"
	var copy_path = "user://data/database"

	var dir = Directory.new()
	print("dir: ",dir.make_dir_recursive(copy_path))
	if dir.open(data_path) == OK:
		dir.list_dir_begin();
		var file_name = dir.get_next()
		while (file_name != ""):
			if dir.current_is_dir():
				pass
			else:
				dir.copy(data_path + "/" + file_name, copy_path + "/" + file_name)
			file_name = dir.get_next()
	else:
		print("failed to access path")

func _exit_tree():
	database.close_db()

