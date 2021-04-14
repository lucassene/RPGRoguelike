extends Node

onready var SQLite = preload("res://addons/godot-sqlite/bin/gdsqlite.gdns")

var database

func load_database():
	database = SQLite.new()
	database.path = _get_db_path()

func query(string):
	database.open_db()
	var result
	database.query(string)
	result = database.query_result
	database.close_db()
	return result

func insert(table,data):
	database.open_db()
	database.insert_row(table,data)
	database.close_db()

func _get_db_path():
	var dir = "res://database/game_database.db"
	if OS.get_name() == "Android" or OS.get_name() == "iOS":
		dir = "user://database/game_database.db"
	return dir

func _exit_tree():
	database.close_db()

