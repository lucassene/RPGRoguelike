extends Resource

const CELL_TABLE = "cell"
const CELL_GROUP_TABLE = "cell_group"
const CELL_TYPE_TABLE = "cell_type"

enum group {BATTLER = 1,SHOP = 2, REST = 3}

static func get_cell_scenes_by_type(type_id):
	var query = "SELECT cell.path FROM cell INNER JOIN cell_type ON cell_type.groupID = cell.groupID WHERE cell_type.ID = %s" % type_id
	return DataAccess.query(query)

static func get_cell_type_by_group(group_id):
	var query = "SELECT ID FROM cell_type WHERE groupID = %s" % group_id
	return DataAccess.query(query)

static func get_cell_type_desc(type_id):
	var query = "SELECT desc FROM cell_type WHERE ID = %s" % type_id
	return DataAccess.query(query)[0].desc
	
static func get_cell_types():
	var query = "SELECT ID FROM cell_type"
	return DataAccess.query(query)

static func get_possible_cell_types(type_id):
	var query = "SELECT nextTypeID,chance FROM cell_chances WHERE typeID = %s ORDER by ID" % type_id
	return DataAccess.query(query)

static func get_forbidden_cells_by_type(type_id):
	var query = "SELECT forbid_typeID FROM cell_forbiddance WHERE typeID = %s" % type_id
	return DataAccess.query(query)

static func get_npcs_by_type(type_id):
	var query = "SELECT npcs FROM cell_type WHERE ID = %s" % type_id
	return DataAccess.query(query)[0].npcs
