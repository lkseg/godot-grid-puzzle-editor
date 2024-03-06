extends Control
const SCENES := "res://scenes/ui/"
const TEXTURES := "res://assets/textures/"


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# @WARNING currently the ui node is scaled
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
const Level_Button := preload("res://scripts/level_button.gd")

var level_button_group := ButtonGroup.new()
var level_button_last_pressed: Level_Button
# @onready var level_buttons := %level_buttons

func load_overworld_pressed() -> bool:
	return %overworld_button.button_pressed
func get_new_level_button_press() -> Level_Button:
	var b := level_button_group.get_pressed_button()
	if b != level_button_last_pressed && b:
		level_button_last_pressed = b
		toggle_hide()
		return b
	return null

func add_empty_directions(count: int) -> void:
	var SC = preload(SCENES+"direction.tscn")
	var dirs := get_node("%directions")
	for child in dirs.get_children():
		child.queue_free()
	for i in count:
		dirs.add_child(SC.instantiate())

func add_direction_icon(d: int, point: int) -> void:
	var sc = get_node("%directions").get_child(point).get_node("texture")
	#sc.pivot_offset = sc.size/2
	match d:
		Game.DIRECTION_FORWARD:
			sc.texture = preload(TEXTURES + "arrow_u.png")
		Game.DIRECTION_RIGHT:
			sc.texture = preload(TEXTURES + "arrow_r.png")			
		Game.DIRECTION_BACK:
			sc.texture = preload(TEXTURES + "arrow_d.png")			
		Game.DIRECTION_LEFT:
			sc.texture = preload(TEXTURES + "arrow_l.png")
		_:
			assert(false)
	
	# get_node("%directions").add_child(sc)

func clear_directions() -> void:
	for child in get_node("%directions").get_children():
		# child.queue_free()
		child.get_node("texture").texture = null

func toggle_hide() -> void:
	%container_level_buttons.visible = !%container_level_buttons.visible

func self_hide() -> void:
	visible = false

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("escape"):
		toggle_hide()
		
