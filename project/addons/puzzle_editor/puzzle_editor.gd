@tool
extends Node3D
class_name Puzzle_Editor
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Each Cell can contain more than one element but with certain restrictions
# e.g. one cell can't contain two collision objects.
# If a cell contains an element then Grid_Cell will exist with one of its elements != null.
# If a cell doesn't contain an element then Grid_Cell itself will be null.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
class Grid_Cell:
	extends RefCounted

	var small: Puzzle_Object
	var big: Puzzle_Object
	func has_collision() -> bool:
		return big != null
	func replace_obj(obj: Puzzle_Object, to: Puzzle_Object):
		if obj.has_collision():
			assert(big == obj)
			big = to
		else:
			assert(small == obj)
			small = to

	func set_obj(obj: Puzzle_Object):
		if obj.has_collision():
			assert(!big)
			big = obj
		else:
			assert(!small)
			small = obj

	func is_empty() -> bool:
		return !small && !big

	func free_if_empty():
		if is_empty():
			# free()
			pass

	# For plugin
	func free_objects():
		if big:
			big.queue_free()
		if small:
			small.queue_free()

	func get_object_type(type: Puzzle_Object.Type) -> Puzzle_Object:
		if big && big.type == type:
			return big
		if small && small.type == type:
			return small
		return null

var grid := {} # Vector3i -> Grid_Cell

const Settings := preload("res://addons/puzzle_editor/settings.gd")


func world_to_map(v: Vector3) -> Vector3i:
	var cell: Vector3i
	cell.x = int(v.x) if v.x >= 0 else floor(v.x)
	cell.y = int(v.y) if v.y >= 0 else floor(v.y)
	cell.z = int(v.z) if v.z >= 0 else floor(v.z)
	return cell

# Just sets the children and keeps them
func load_grid_from_children_directly() -> void:
	grid = {}
	for child in get_children():
		var cell := world_to_map(child.global_position)
		child.cell = cell
		set_cell(child.cell, child)

func load_character() -> Dynamic_Object:
	var obj = load(Settings.OBJ+"player.tscn").instantiate()
	obj.type = Settings.T.Character
	return obj

func _ready():
	if Engine.is_editor_hint():		
		load_grid_from_children_directly()
	else:
		# Dictionary gets set to {} at game start
		load_grid_from_children_directly()

func get_object_type(cell: Vector3i, type: Puzzle_Object.Type) -> Puzzle_Object:
	return get_cell(cell).get_object_type(type)

func get_cell(cell: Vector3i) -> Grid_Cell:
	return grid.get(cell, null)

func get_cell_xz(cell: Vector3i, y: int = 0) -> Grid_Cell:
	return grid.get(Vector3i(cell.x, y, cell.z), null)

func get_celli(x: int, y: int, z: int) -> Grid_Cell:
	return grid.get(Vector3i(x,y,z), null)

func safe_set_cell(cell: Vector3i, obj: Puzzle_Object) -> void:
	var c := get_cell(cell)
	if c && c.has_collision() == obj.has_collision():
		assert(false, "Cell already contains object")
		return
	set_cell(cell, obj)


func set_cell(cell: Vector3i, obj: Puzzle_Object) -> void:
	if !grid.has(cell):
		grid[cell] = Grid_Cell.new()
		
	if obj.has_collision():
		grid[cell].big = obj
	else:
		grid[cell].small = obj
		
	obj.cell = cell
		

func remove_from_cell(obj: Puzzle_Object) -> void:
	var c := get_cell(obj.cell)
	assert(c)
	c.replace_obj(obj, null)
	c.free_if_empty()

# just cell not object!
func remove_cell(cell: Vector3i) -> bool:
	var c := get_cell(cell)
	if c:
		# c.free()
		pass
	else: 
		return false
	grid.erase(cell)
	return true


# just clears grid doesn't free children
func clear_grid():
	grid.clear()

func clear():
	for key in grid:
		var it = grid[key]
		it.free_objects()

	grid.clear()







 
