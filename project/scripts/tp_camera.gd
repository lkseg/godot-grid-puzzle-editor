extends Camera3D


@export var rot_scale: float =0.005


var cursor_anchor: Vector2
var player: Node3D
var base_offset: Vector3
var spring_arm: SpringArm3D
# the camera 

func _enter_tree() -> void:
	#get_parent().top_level = true
	
	spring_arm = get_parent().get_parent()
	
	player = %player
	# we take the local position of the target as global offset
	

func _ready() -> void:
	# local position is offset
	position.y = 0.8
	
	# Input.set_mouse_mode(2)
	pass

func _input(event: InputEvent) -> void:
	var mouse_r := Input.is_action_pressed("mouse_r")
	var mouse_l := Input.is_action_pressed("mouse_l")
	var mouse_m := Input.is_action_pressed("mouse_m")
	if mouse_r || mouse_l:
		#App.cursor.lock()
		pass
		
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			spring_arm.spring_length = min(spring_arm.spring_length+event.factor, 100)
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			spring_arm.spring_length = max(spring_arm.spring_length-event.factor, 0.1)
			
	if event is InputEventMouseMotion:	
		rotate_around_base(event.relative)
		pass
		# rotate_around_base(event.relative)
		# if Input.is_action_pressed("ui_mouse_left"):
		# 	Input.set_mouse_mode(2)
		# 	_quat_rot(event)
		# else:
		# 	Input.set_mouse_mode(0)
	if !mouse_r && !mouse_l:
		#App.cursor.unlock()
		pass
		



func _process(delta) -> void:
	spring_arm.global_position = player.global_position
	pass

func _physics_process(delta) -> void:
	pass


func get_frontal() -> Vector3:
	return -get_global_transform().basis.z

func get_frontal_x0z() -> Vector3:
	var v := -get_global_transform().basis.z
	return Vector3(v.x, 0., v.z)



# We use our parent to rotate around the y axis.
# We ourselves rotate around the x axis and set the rotation vector as our local position
func rotate_around_base(move: Vector2) -> void:
	const THETA_DIFF := 0.2
	const theta_lim := Vector2(-PI/2 + THETA_DIFF, PI/2 - THETA_DIFF)
	var rot_x_inv := 1.
	var rot_y_inv := -1.
	var rot_scale := 0.005

	spring_arm.rotation.y += rot_y_inv * move.x * rot_scale
	var rot := spring_arm.rotation.x + rot_x_inv * move.y * rot_scale
	rot = clamp(rot, theta_lim.x, theta_lim.y)
	spring_arm.rotation.x = rot

	""" rotx += -move.y*rot_scale
	rotx = clamp(rotx, min_rotx, max_rotx)
	
	quat = Quaternion(Vector3.RIGHT, rotx)
	position = quat*tc
	base.rotation.y += -move.x*rot_scale
	
	look_at(base.global_position, Vector3.UP)
	orthonormalize() """
	
func update_pos() -> void:	
	pass

	
