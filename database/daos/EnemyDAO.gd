extends Resource

const ENEMY_TABLE = "enemy"

func get_enemies():
	var query = "SELECT * FROM enemy"
	return DataAccess.query(query)
