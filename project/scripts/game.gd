extends Node3D
class_name Game

# @sync with plugin / settings.gd
const CUBE_LEN := 1.
const CUBE_SIZE := Vector3(CUBE_LEN,CUBE_LEN,CUBE_LEN)
const CUBE_SIZE_XZ := Vector3(CUBE_SIZE.x,0.,CUBE_SIZE.z)

enum{STATE_INPUT, STATE_PLAY}
enum{DIRECTION_FORWARD = 0, DIRECTION_RIGHT, DIRECTION_BACK, DIRECTION_LEFT}

const DIRECTION_VEC: Array[Vector3i] = [Vector3i(0,0,-1), Vector3i(1,0,0), Vector3i(0,0,1), Vector3i(-1,0,0)]
const OT = Puzzle_Object.Type

const Level_Button := preload("res://scripts/level_button.gd")
# const Block := preload("res://scripts/block.gd")
const Overworld := preload("res://scenes/overworld.tscn")

var init_level := "level_1_2"

var max_input_size := 4
var input_mem: Array[int]

var input_timer := 0.0
var input_tick := 0.2

@onready var ui := get_node("%ui")

var grid: Puzzle_Editor
var player: Puzzle_Object
var level: Level

var start_cell: Vector3i


var current_input := 0
var initial_state := {} # Puzzle_Object -> Dictionary(State)

class Game_State extends RefCounted:	
	var paused := false
	var playing := false
	var won := false
	

var game_state := Game_State.new()

func load_level_list() -> void:
	var lb := ui.get_node("%level_buttons")	
	var levels := {}
	App.load_all_dir_threaded(levels, "res://scenes/", ["levels/"])
	for l_name in levels:
		var b := Level_Button.new(levels[l_name])
		b.text = l_name.trim_suffix(".tscn")
		b.toggle_mode = true
		b.button_group = ui.level_button_group		
		lb.add_child(b)

func unload_level() -> void:
	remove_child(level)
	level.queue_free()

func load_level(level_name: String) -> void:
	return load_level_scene(load("res://scenes/levels/%s.tscn" % level_name))

func load_level_scene(scene: PackedScene) -> void:
	initial_state.clear()
	level = scene.instantiate()
	add_child(level)
	max_input_size = level.max_input_size
	grid = level.get_node("puzzle_editor")
	start_game()
	ui.add_empty_directions(max_input_size)
	

func _enter_tree() -> void:
	pass
	
	
func _ready() -> void:
	load_level_list()
	load_level(init_level)
	# level = get_node("level") as Level
	


func init_object(p: Puzzle_Object):
	if !p: return
	initial_state[p] = p.save_state()
	if p is Dynamic_Object:
		p.post_init(self, grid)
func start_game() -> void:
	# No INT_MIN in godot???
	var max_y := -1000000
	# Keys since we might remove one during iteration
	for cell in grid.grid.keys():
		var it := grid.get_cell(cell).small
		max_y = max(max_y, cell.y)
		if it && it.type == Puzzle_Object.Type.Player_Start:
			grid.remove_cell(cell)
			it.queue_free()
			var c := grid.load_character()			
			grid.safe_set_cell(cell, c)
			player = c
			start_cell = cell
			# break
		var c := grid.get_cell(cell)
		init_object(c.small)
		init_object(c.big)

	assert(max_y > -1000000)
	
	for cell in grid.grid:
		var it := grid.get_cell(cell)
		var obj := grid.get_object_type(cell, OT.Block)
		
		if cell.y == max_y && obj:
			obj._on_is_not_top_block()
			pass

	assert(player)
	clear_input_mem()
	game_state = Game_State.new()

func update_position(obj: Puzzle_Object) -> void:
	obj.update_position(cell_to_world(obj.cell))

func init_position(obj: Puzzle_Object) -> void:
	obj.init_position(cell_to_world(obj.cell))

func push_cell(obj: Puzzle_Object, dir: Vector3i) -> bool:
	assert(dir.length_squared() == 1)
	var other := grid.get_cell(obj.cell + dir)
	assert(other && other.has_collision())
	var to_cell := obj.cell + 2*dir
	var to := grid.get_cell(to_cell)
	if to && to.big:
		return false
	if !grid.get_cell_xz(to_cell, to_cell.y-1):
		return false
	move_cell(other.big, to_cell)
	move_cell(obj, obj.cell + dir)
	return true

func set_cell(cell: Vector3i, obj: Puzzle_Object):
	grid.set_cell(cell, obj)
	update_position(obj)

func set_init_cell(cell: Vector3i, obj: Puzzle_Object):
	grid.set_cell(cell, obj)
	init_position(obj)

func move_cell(obj: Puzzle_Object, cell: Vector3i):
	var other := grid.get_cell(cell)
	assert(!other || other.has_collision() != obj.has_collision())
	grid.remove_from_cell(obj)
	var from := obj.cell
	set_cell(cell, obj)	
	obj._on_moved(from)
	


func recover_initial_game_state() -> void:
	grid.clear_grid()	
	for obj in initial_state:		
		var it = initial_state[obj]
		obj.reset()
		set_init_cell(it.cell, obj)
		
	clear_input_mem()
	game_state = Game_State.new()



# upper left corner is at cell so offset it by SIZE/2
func cell_to_world(v: Vector3i) -> Vector3:
	return Vector3(v) + CUBE_SIZE_XZ/2.
	
func get_input_direction() -> int:
	if Input.is_action_just_pressed("forward"):
		return DIRECTION_FORWARD
	if Input.is_action_just_pressed("right"):
		return DIRECTION_RIGHT
	if Input.is_action_just_pressed("back"):
		return DIRECTION_BACK
	if Input.is_action_just_pressed("left"):
		return DIRECTION_LEFT
	return -1

func clear_input_mem() -> void:
	input_mem.clear()
	ui.clear_directions()
	input_timer = 0

func _process(delta: float) -> void:
	if ui.load_overworld_pressed():
		set_process(false)
		unload_level()
		ui.self_hide()
		add_child(Overworld.instantiate())
		return

	var new_level := ui.get_new_level_button_press() as Level_Button
	if new_level:
		unload_level()
		load_level_scene(new_level.scene)

	if Input.is_action_just_pressed("pause_game"):
		game_state.paused = !game_state.paused
		print("pause game ", game_state.paused)
		assert(false)

	if game_state.playing:
		process_game(delta)
		if !game_state.playing:
			if !game_state.won:
				recover_initial_game_state()
		return
	
	if !game_state.won:
		if Input.is_action_just_pressed("clear_input"):
			clear_input_mem()
		var input := get_input_direction()
		if input >= 0 && input_mem.size() < max_input_size:
			input_mem.push_back(input)
			ui.add_direction_icon(input, input_mem.size()-1)
			
		if Input.is_action_just_pressed("execute_input") && input_mem.size() > 0:
			start_round()


func check_win_condition() -> bool:
	var obj := grid.get_cell(player.cell)

	if obj && obj.small && obj.small.type == Puzzle_Object.Type.Goal:
		game_state.won = true
		return true
	return false


# Returns true when *player* moved successfully.
# An unsuccessful move means the next input should be chosen.
func move_player(d: Vector3i) -> bool:	
	
	var to := player.cell + d
	var bot := grid.get_celli(to.x, to.y-1, to.z)
	var obj := grid.get_cell(to)
	
	if !bot:
		return false

	if obj && obj.has_collision() && obj.big.type == OT.Crate:
		var pushed := push_cell(player, d)
		return pushed
	if obj && obj.has_collision():
		return false
	move_cell(player, to)
	# player.force_update_position()
	obj = grid.get_cell(to)

	return true

# Returns true when the game is finished and won.
func process_game(delta: float) -> bool:
	input_timer += delta
	if input_timer <= input_tick:
		return false
	input_timer = 0
	var it := input_mem[current_input]
	if !move_player(DIRECTION_VEC[it]):
		set_current_input(current_input + 1)
	var is_win := check_win_condition()	
	if current_input >= input_mem.size() || is_win:
		game_state.playing = false
		if game_state.won:
			return true
		return false
	return false
		

func excute_next_input() -> bool:	
	return true

func set_current_input(val: int):
	current_input = val
	input_timer = 0

func start_round() -> void:
	game_state = Game_State.new()
	game_state.playing = true
	set_current_input(0)

			# player.force_update_position()
