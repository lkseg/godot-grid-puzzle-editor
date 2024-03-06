extends Resource


const CUBE_LEN := 1.
const CUBE_SIZE := Vector3(CUBE_LEN,CUBE_LEN,CUBE_LEN)
const CUBE_SIZE_XZ := Vector3(CUBE_SIZE.x,0.,CUBE_SIZE.z)

const EXT = ".png"
const OBJ = "res://scenes/game_objects/"
const ICONS = "res://assets/item_icons/"
const ICON_START = "start" + EXT
const ICON_CRATE = "crate" + EXT
const ICON_BLOCK = "block" + EXT

const ICON_GOAL = "goal" + EXT

const T = Puzzle_Object.Type
# adds them to the editor for insertion
var load_items := {
	"block": [preload(ICONS + ICON_BLOCK), T.Block],	
	"crate": [preload(ICONS + ICON_CRATE), T.Crate],
	"start": [preload(ICONS + ICON_START), T.Player_Start],
	"goal":  [preload(ICONS + ICON_GOAL),  T.Goal],
}


static func load_object(type: T) -> Puzzle_Object:
	var obj: Puzzle_Object
	match type:
		T.Block:
			obj = preload(OBJ + "block.tscn").instantiate()
		T.Player_Start:
			obj = preload(OBJ + "player_start.tscn").instantiate()
		T.Goal:
			obj = preload(OBJ + "goal.tscn").instantiate()
		T.Crate:			
			obj = preload(OBJ + "crate.tscn").instantiate()
		_:
			assert(false)	
	obj.type = type
	assert(obj, "object type not implemented")
	return obj
