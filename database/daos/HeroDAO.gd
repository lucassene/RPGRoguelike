extends Resource

const HERO_TABLE = "hero"

static func get_heroes_in_party():
	var query = "SELECT * FROM hero WHERE inParty = 1"
	return DataAccess.query(query)

