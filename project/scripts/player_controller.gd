extends Node

@export var character: Character


var hovered: Node3D

var ray_param := PhysicsRayQueryParameters3D.new()
var camera: Camera3D
var puzzle
func _enter_tree() -> void:
	ray_param.collide_with_areas = false
	ray_param.collide_with_bodies = true
	ray_param.collision_mask = 0xFFFFFFFF
	ray_param.exclude = []
	ray_param.hit_back_faces = true
	ray_param.hit_from_inside = false

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera = %player_camera
	character.controller = self

func _on_entered_puzzle(_puzzle) -> void:
	puzzle = _puzzle

func _on_left_unsolved_puzzle(_puzzle) -> void:
	puzzle = null

func _on_finished_puzzle() -> void:
	puzzle = null


func _process(delta: float)	-> void:
	if puzzle:
		if Input.is_action_just_pressed("reset"):
			puzzle.reset()
		if Input.is_action_just_pressed("cheat_solve"):
			puzzle.cheat_solve()
		if Input.is_action_just_pressed("shuffle"):
			if puzzle.is_random_puzzle():
				puzzle.reset_shuffle()


func _physics_process(delta: float)	-> void:
	handle_movement_input(delta)

func physics_handle_mouse() -> void:
	var d := cursor_cast_ray()
	
	if !d.is_empty():
		if hovered != d.collider && hovered != null:
			hovered._on_mouse_exited()
			hovered = null
			
		if d.collider.has_method("_on_mouse_entered"):
			hovered = d.collider
			hovered._on_mouse_entered()
			
	elif hovered != null:
			hovered._on_mouse_exited()
			hovered = null

	# TODO properly reconsider when target should be cleared
	# right now it is only being cleared when nothing is being hit
	# (hitting nothing does not clear it but hitting the ground does atm)
	if Input.is_action_just_pressed("mouse_l"):
		if !d.is_empty():
			if d.collider.get("is_entity"):
				pass
			else:
				pass #clear_target()
		else:
			pass
			# clear_target()
	pass

# casts ray from e's position down
func cast_ray_down(e: Node3D) -> Dictionary:
	ray_param.from = e.global_position
	ray_param.to = ray_param.from + Vector3.DOWN * 1000
	return character.get_world_3d().direct_space_state.intersect_ray(ray_param)



func cursor_cast_ray() -> Dictionary:
	var pos := App.get_cursor_position()
	ray_param.from = camera.project_ray_origin(pos)
	ray_param.to = ray_param.from + camera.project_ray_normal(pos) * 1000
	return character.get_world_3d().direct_space_state.intersect_ray(ray_param)

func handle_movement_input(delta: float) -> void:
	var input_velocity := Vector3.ZERO

	var zdir = -camera.get_global_transform().basis.z
	zdir.y = 0
	zdir = zdir.normalized()
	
	var x_input = Input.get_action_strength("right")-Input.get_action_strength("left")
	var z_input = Input.get_action_strength("forward")-Input.get_action_strength("back")
	var xdir = zdir.rotated(Vector3.UP,-PI/2) # weird way to get the x_axis
	input_velocity += xdir * x_input
	input_velocity += zdir * z_input

	# Move in camera direction
	if Input.is_action_pressed("mouse_l") && Input.is_action_pressed("mouse_r"):
		input_velocity += zdir
		# movement_used_mouse = true

	input_velocity = input_velocity.normalized()
	
	
	var bjump := Input.is_action_just_pressed("jump") && character.is_on_floor()
	
	character.character_physics_process(delta, input_velocity, bjump)
	
	# var to := position + camera.get_frontal_x0z() as Vector3

