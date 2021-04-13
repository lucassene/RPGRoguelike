extends Resource

var enemy_dao_path = "res://database/daos/EnemyDAO.gd"
var enemy_dao

func initialize():
	enemy_dao = load(enemy_dao_path).new()
	
func get_enemies():
	return enemy_dao.get_enemies()

