extends Node


var use_custom_cursor := false
var show_debug := false
const COLLISION_LAYER := 1 << 0
const ENTITY_LAYER := 1 << 1

# 
var ticks_per_second := int(60)

func _input(event) -> void:
	if !OS.is_debug_build(): return
	if event is InputEventKey:
		if Input.is_action_pressed("shift") && event.pressed and event.keycode == KEY_C:
			get_tree().quit()

func _enter_tree() -> void:
	# they should be pretty much equal to prevent jitter
	# maybe look at physics_jitter_fix for an alternative approach
	Engine.set_max_fps(ticks_per_second)
	Engine.set_physics_ticks_per_second(ticks_per_second)
	# if use_custom_cursor:
	# 	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	# else:
	# 	Input.mouse_mode = Input.MOUSE_MODE_CONFINED
	pass
			
func _ready() -> void:
	#print_tree_pretty()
	add_standard_actions()
	# DisplayServer.window_set_size(Vector2i(16, 9) * 100)

	#RenderingServer.global_shader_parameter_add(
	#	"camera_position_world", RenderingServer.GLOBAL_VAR_TYPE_VEC3, Vector3(0,0,0))
	#get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("show_debug"):
		show_debug = !show_debug

func add_standard_actions()->void:
	create_action("forward", KEY_W)
	create_action("right", KEY_D)
	create_action("left", KEY_A)
	create_action("back", KEY_S)
	create_action("clear_input", KEY_C)
	create_action("reset", KEY_R)
	create_action("shuffle", KEY_V)
	create_action("cheat_solve", KEY_G)
	create_action("jump", KEY_SPACE)
	create_action("execute_input", KEY_SPACE)
	
	create_action("debug_test", KEY_T)

	create_action("attack", KEY_A)
	create_action("shift", KEY_SHIFT)
	create_action("alt", KEY_ALT)
	
	create_action("quick_save_game", KEY_U)
	create_action("rotate", KEY_E)
	create_action("pause_game", KEY_F)
	create_action("escape", KEY_ESCAPE)
	
	create_action("0_0", KEY_1)
	create_action("0_1", KEY_2)
	create_action("0_2", KEY_3)
	create_action("0_3", KEY_4)
	create_action("0_4", KEY_5)


	if OS.is_debug_build():
		create_action("show_debug", KEY_H)
	
	create_mouse_action("mouse_l",MOUSE_BUTTON_LEFT)
	create_mouse_action("mouse_r",MOUSE_BUTTON_RIGHT)
	create_mouse_action("mouse_m",MOUSE_BUTTON_MIDDLE)

	create_action("a1", KEY_Q)
	
	create_action("action", KEY_F)
	pass



func create_action(_name: String ,code: int) -> void:
	InputMap.add_action(_name)
	action_add_key(_name,code)

func action_add_key(_name: String, code: int) -> void:
	var event=InputEventKey.new()
	event.keycode=code #keycode in 4.0
	InputMap.action_add_event(_name,event)		

func create_mouse_action(_name: String, code: int) -> void:
	InputMap.add_action(_name)
	action_add_mouse_button(_name,code)

func action_add_mouse_button(_name: String,code: int) -> void:
	var event=InputEventMouseButton.new()
	event.button_index=code
	InputMap.action_add_event(_name,event)		
	

