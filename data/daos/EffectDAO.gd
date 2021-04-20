extends Resource

const EFFECT_TABLE = "effect"

func get_effect_info(effect_id):
	var query = "SELECT * FROM effect WHERE ID = %s" % effect_id
	return DataAccess.query(query)[0]

