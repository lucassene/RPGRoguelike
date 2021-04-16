const HERO_NAME_TABLE = "hero_name"
const HERO_TOKEN_TABLE = "hero_token"

static func get_hero_names():
	var query = "SELECT string FROM hero_name"
	return DataAccess.query(query)

static func get_hero_tokens():
	var query = "SELECT path FROM hero_token"
	return DataAccess.query(query)
