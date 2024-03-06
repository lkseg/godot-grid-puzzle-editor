@tool
extends Node3D
class_name Puzzle_Object
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# All Objects that inherit from this class must be a @tool.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

enum Type {Block = 1, Player_Start, Crate, Character, Goal}

# Only exported vars get saved. Important for saving the scene
@export var cell: Vector3i
@export var type: Type

func _validate_property(v: Dictionary):	
	if v.name in ["cell"]:
		v.usage = PROPERTY_USAGE_NO_EDITOR

# var properties = get_script().get_script_property_list()
func _init():
	pass

func has_collision() -> bool:
	match type:
		Type.Block, Type.Character, Type.Crate:
			return true
			
	return false

func save_state() -> Dictionary:
	var dict := {
		"cell": cell,
	}
	return dict


func save() -> Dictionary:    
	var dict := {
		"cell": cell,
		"type": type,
	}
	return dict

func init_position(v: Vector3) -> void:
	global_position = v
# @virtual
func _on_moved(from: Vector3i) -> void:
	pass

# @virtual
func update_position(v: Vector3) -> void:
	global_position = v

# @virtual
# Called when the level gets reseted. Called before the cell is being set.
func reset() -> void:
	pass
