@tool
extends Puzzle_Object
class_name Static_Object


const Block_Dirt_Asset := preload("res://assets/objects/basic/block_low.tscn")

func _on_moved(c: Vector3i) -> void:
	print("moved static", c)
	assert(false)

func _on_is_not_top_block() -> void:
	
	assert(!Engine.is_editor_hint() && type == Type.Block)
	$model.queue_free()
	var a := Block_Dirt_Asset.instantiate()
	a.position.y = -0.5
	add_child(a)		

