extends Node3D

var puzzle
var player

func _ready() -> void:
	$area.body_entered.connect(_on_body_entered)
	$area.body_exited.connect(_on_body_exited)
	puzzle = $puzzle
	assert(puzzle)
	var s := get_node_or_null("solved") as Node3D
	if s:
		s.visible = false
	


func _on_solved() -> void:
	if !player:
		return
	player._on_finished_puzzle()
	open_exit()
	
	var s := get_node_or_null("solved") as Node3D
	if s:
		s.visible = true
	
	
func open_exit() -> void:
	var exit := $exit
	for node in exit.get_children():
		node.queue_free()

	
func _on_body_entered(node: Node3D) -> void:
	if puzzle.solved:
		return
	var c = node.get("controller")
	if !c: return
	c._on_entered_puzzle(puzzle)
	player = c

func _on_body_exited(node: Node3D) -> void:
	if puzzle.solved:
		return
	var c = node.get("controller")
	if !c: return
	c._on_left_unsolved_puzzle(puzzle)
	puzzle.reset()
	player = null
	


