@tool
extends Node3D

const pawn_scene := preload("res://scenes/puzzle_clock_object.tscn")
const hand_scene := preload("res://scenes/puzzle_clock_hand.tscn")

const Pawn := preload("res://scripts/puzzle_clock_object.gd")


enum State {Idle, First_Move, Second_Move}

var move_from: Pawn

var state := State.Idle: set = set_state

func set_state(s: State) -> void:
	state = s
	state_duration = 0.

var state_duration := 0.

class Clock_Hand:
	var node: Node3D
	var pawn: int = 0

# They move in opposite directions
var hand_1 := Clock_Hand.new()
var hand_2 := Clock_Hand.new()


var move_duration := 0.8
var first_move: bool

var solved := false

var hand_tween: Tween

@export var pawns := []

@export var t_reset := false: set = set_t_reset

func set_t_reset(_v: bool) -> void:
	set_count(count)

@export var count := 7: set = set_count

@export var radius := 4:
	set(r):
		radius = r
		set_count(count)

@export var gen_random := false

func _validate_property(v: Dictionary):	
	if v.name in ["pawns"]:
		v.usage = PROPERTY_USAGE_NO_EDITOR




func _ready() -> void:	
	if Engine.is_editor_hint():
		return
	make_hands()
	if gen_random:
		var vals := random_generation()
		update_nodes_for_count(vals.size())
		for i in pawns.size():
			pawns[i].value = vals[i]
		
	start_game()

func _process(delta: float):
	if Engine.is_editor_hint():
		return

	if solved:
		return
	if check_if_solved():
		_on_solved()
		return

	state_duration += delta
	match state:
		State.Idle:
			pass
		State.First_Move:
			if state_duration > move_duration:
				set_state(State.Second_Move)				
		State.Second_Move:
			if state_duration > move_duration:
				move_hands(move_from.value)
				set_state(State.Idle)

func make_hands() -> void:
	if hand_1.node:
		hand_1.node.free()
	if hand_2.node:
		hand_2.node.free()
	hand_1.node = hand_scene.instantiate()
	hand_2.node = hand_scene.instantiate()
	add_child(hand_1.node)
	add_child(hand_2.node)
	# hand_2.node.position.y = 0.5
	hand_1.node.name = "hand_1"
	hand_2.node.name = "hand_2"				

func start_game() -> void:
	state = State.Idle
	first_move  = true
	solved = false
	for p in pawns:
		p.set_active()
		p.set_usable()

func both_point_at_position(pos: Vector3) -> void:
	point_at_position(hand_1, pos)
	point_at_position(hand_2, pos)


func point_at_position(hand: Clock_Hand, pos: Vector3) -> void:
	var n := hand.node
	pos.y = n.global_position.y	
	hand_tween = get_tree().create_tween()
	hand_tween.tween_method(n.look_at.bind(Vector3.UP), n.global_position - n.global_basis.z, pos, move_duration)


func point_at(hand: Clock_Hand, pawn: Pawn) -> void:
	hand.pawn = pawn.id
	pawn.set_usable(true)
	point_at_position(hand, pawn.global_position)
	# hand.node.look_at(pos)
	# get_tree().create_tween().tween_property(hand)
	

func move_hands(value: int) -> void:
	point_at(hand_1, pawns[posmod(hand_1.pawn-value, pawns.size())])	
	point_at(hand_2, pawns[posmod(hand_2.pawn+value, pawns.size())])	
	pass


func _on_entered_object(node: Pawn) -> bool:
	if state != State.Idle:
		return false
	set_state(State.First_Move)
	if first_move:
		first_move = false
	for p in pawns:
		p.set_usable(false)

	both_point_at_position(node.global_position)
	hand_1.pawn = node.id
	hand_2.pawn = node.id
	move_from = node
		
	return true

func set_count(n: int):
	if Engine.is_editor_hint() && is_inside_tree():
		count = n
		update_nodes_for_count(n)

func update_nodes_for_count(n: int):
	if n % 2 == 0:
		printerr("count must be uneven")
		return
	
	
	if Engine.is_editor_hint():
		for child in get_children():
			child.queue_free()
		await get_tree().process_frame
		await get_tree().process_frame

	var d := 2.*PI/float(n)
	var angle := 0.
	pawns.clear()
	pawns.resize(n)
	var eis: Node
	if Engine.is_editor_hint():
		eis = EditorInterface.get_edited_scene_root()
	for i in n:
		var pawn := pawn_scene.instantiate()        
		pawn.id = i
		add_child(pawn)
		
		var vec := Vector3(0,0,-radius)
		var p := vec.rotated(Vector3.UP, angle)
		pawn.position = p
		angle += d
		pawns[i] = pawn
		pawn.name = "pawn_" + str(i)
		if Engine.is_editor_hint():
			pawn.set_owner(eis)

func check_if_solved() -> bool:
	if solved:
		return true

	for pawn in pawns:
		if pawn.active:
			return false
				
	return true



func _on_solved() -> void:
	solved = true
	if !is_random_puzzle():
		get_parent()._on_solved()

func cheat_solve() -> void:
	for pawn in pawns:
		pawn.set_active(false)
	_on_solved()


func reset():
	if hand_tween:
		hand_tween.kill()
		hand_tween = null
	make_hands()
	start_game()



# a, b in [0, n-1]
func wrapped_abs_min(a: int, b: int, n: int) -> int:
	return min(abs(b-a), abs(n-b)+a, abs(n-a)+b)

func random_generation() -> Array[int]:
	var n := 11
	var max_jump := n/2
	var nums: Array[int]
	nums.resize(n)
	for i in n: nums[i] = i

	var p: Array[int]
	p.resize(n)
	p.fill(-1)
	var a := randi_range(0, n-1)
	var solution: Array[int]
	solution.push_back(a)

	for i in n:
		nums.shuffle()
		for b in nums:
			if a == b || p[b] >= 0: continue
			# @todo Random here first
			var val := wrapped_abs_min(a,b,n)
			assert(0 < val && val <= max_jump)			
			p[a] = val
			# next			
			a = b			
			solution.push_back(a)
			continue
	# print(p)
	assert(p[a] == -1)
	p[a] = randi_range(1, max_jump)
	print(solution)
	# This is very dangerous since it depends on the setters only running in editor mode
	radius = 4.
	count = n
	return p

func is_random_puzzle() -> bool:
	return gen_random

func reset_shuffle() -> void:
	for child in get_children():
		child.queue_free()
	var vals := random_generation()
	update_nodes_for_count(vals.size())
	for i in pawns.size():
		pawns[i].value = vals[i]
	reset()
			
			

	

