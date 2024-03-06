@tool
extends Puzzle_Object
class_name Dynamic_Object


var move_timer := FTimer.new(0.2, true)
var game: Game
var moved_from: Vector3i
var rotate_in_direction := false


func post_init(_game: Game, parent: Node) -> void:
	game = _game
	if !get_parent():
		parent.add_child(self)
	force_update_position()
	
func _process(delta: float) -> void:
	var model = get_node_or_null("model")
	if !move_timer.done():
		var from := game.cell_to_world(moved_from)		
		var to := game.cell_to_world(cell)
		global_position = from.lerp(to, move_timer.progress())
		if rotate_in_direction:
			model.look_at(model.global_position + (to - from))
		if model:
			# model._set_walk_run_blending(1.)
			model.walk()
	else:
		if model:
			model.idle()
	move_timer.step(delta)
			
		# var d := move_to - cell

func force_update_position() -> void:
	set_global_position.call_deferred(game.cell_to_world(cell))

func _on_moved(from: Vector3i) -> void:
	moved_from = from
	move_timer.start()

func update_position(_v: Vector3) -> void:
	pass

func reset() -> void:
	move_timer.finish()
	pass
