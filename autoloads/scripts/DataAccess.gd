extends Node

onready var SQLite = preload("res://addons/godot-sqlite/bin/gdsqlite.gdns")

var database

func load_database():
	database = SQLite.new()
	database.path = _get_db_path()

func open_database():
	database.open_db()

func close_database():
	database.close_db()

func query(string):
	var result
	database.query(string)
	result = database.query_result
	return result

func insert(table,data):
	database.insert_row(table,data)

func _get_db_path():
	var dir = "res://database/game_database.db"
	if OS.get_name() == "Android" or OS.get_name() == "iOS":
		dir = "user://database/game_database.db"
	return dir

