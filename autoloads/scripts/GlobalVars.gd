extends Node

enum direction {WEST,NORTH,EAST}
enum actor_type {PLAYER,NPC,ENEMY,ENEMY_NPC}
enum skill_range {SELF = 1,MELEE = 2,SHORT = 3,LONG = 4}
enum skill_target {SELF = 1,ALLY = 2,ENEMY = 3,ALLIES_ALL = 4,ENEMIES_ALL = 5,ALL = 6,SPACE = 7}

const CELL_SIZE = Vector2(180,180)

