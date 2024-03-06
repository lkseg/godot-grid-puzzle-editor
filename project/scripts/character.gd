extends CharacterBody3D
class_name Character


@export var speed: float = 6.
@export var jump_maximum := Vector2(110,100)

var input_velocity := Vector3.ZERO

var initial_jump_speed: float
var gravity_speed: float
var jump_velocity: Vector3
var gravity_velocity: Vector3

var can_jump := false

var controller

const Y_DELTA := 0.05

func _ready() -> void:
	
	initial_jump_speed  = 2*jump_maximum.y*speed/jump_maximum.x
	gravity_speed       = 2*jump_maximum.y*speed*speed/(jump_maximum.x*jump_maximum.x)
	jump_velocity       = Vector3.UP*initial_jump_speed
	gravity_velocity    = Vector3.DOWN*gravity_speed

	
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pass # Replace with function body.


	
func _process(delta: float) -> void:
	pass


func model_look_at(look_at_pos := Vector3.INF) -> void:
	var model := $model
	if look_at_pos == Vector3.INF:
		var vxz := Vector3(velocity.x, 0, velocity.z).normalized()
		if !vxz.is_zero_approx():
			model.look_at(model.global_position + vxz)
	else:
		var vxz := Vector3(look_at_pos.x, model.global_position.y, look_at_pos.z)
		if !vxz.is_zero_approx():
			model.look_at(vxz)	

func character_physics_process(delta: float, input_velocity: Vector3, jump: bool, look_at_pos := Vector3.INF) -> void:
	input_velocity *= speed
	if jump:
		input_velocity += jump_velocity		
	if !is_on_floor():
		input_velocity += gravity_velocity
		
	velocity = Vector3(input_velocity.x,velocity.y+input_velocity.y,input_velocity.z)
	move_and_slide()
	var model := get_node_or_null("model")
	
	if !model:
		return
	if velocity.length_squared() > 0:
		var vxz := Vector3(velocity.x, 0, velocity.z).normalized()
		if !vxz.is_zero_approx():
			model_look_at(model.global_position + vxz)
		if velocity.y > Y_DELTA:
			model.jump()	
		elif velocity.y < -Y_DELTA:
			model.fall()
		else:
			model.walk()
	else:
		model.idle()
func _physics_process(delta: float) -> void:
	pass
		
	
	










# func _on_mouse_entered() -> void:
# 	var m = $model.get_active_material(0)
# 	m.next_pass = Data.outline
# 	pass
# 
# func _on_mouse_exited() -> void:
# 	var m = $model.get_active_material(0)
# 	m.next_pass = null
# 	pass
