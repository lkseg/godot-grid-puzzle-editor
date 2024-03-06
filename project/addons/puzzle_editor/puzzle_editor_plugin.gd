@tool
extends EditorPlugin


# A class member to hold the dock during the plugin life cycle.

var preview
var preview_plane
var left_container
var item_container_button_group := ButtonGroup.new()

var cell_label: Label
var camera: Camera3D
var viewport: SubViewport
var cursor_cell: Vector3i
var plane_level: int = 0
var editor: Puzzle_Editor = null

var in_valid_state := false

const PATH := "res://addons/puzzle_editor/"

const Settings := preload(PATH + "settings.gd")
const Item_Button := preload(PATH + "item_button.tscn")

var settings: Settings
var selected_item = null

# var settings = preload(PATH + "settings.gd").new()
func _enter_tree():
	viewport = EditorInterface.get_editor_viewport_3d(0)
	# viewport = get_viewport()
	camera = viewport.get_camera_3d()



func make_self():
	in_valid_state = true
	# always reload for dev time
	settings = preload(PATH + "settings.gd").new()
	left_container = preload(PATH+"left_container.tscn").instantiate()	
	
	# button = preload(PATH+"button.tscn").instantiate()
	preview = preload(PATH+"preview_cube.tscn").instantiate()
	preview_plane = preload(PATH+"preview_plane.tscn").instantiate()	
	cell_label = Label.new()
	
	# button.text = "ABC"
	add_control_to_container(CONTAINER_SPATIAL_EDITOR_MENU, cell_label)
	add_control_to_container(CONTAINER_SPATIAL_EDITOR_SIDE_LEFT, left_container)
	# EditorInterface.get_editor_main_screen().add_child(help_label)
	
	add_child(preview)
	add_child(preview_plane)
	
	cell_label.text = "cell"
	# await get_tree().process_frame
	var item_container = left_container.get_node("item_container")
	assert(item_container)
	for key in settings.load_items:
		var item := Item_Button.instantiate()
		var c = settings.load_items[key]
		item.icon = c[0]
		item.toggle_mode = true
		item.button_group = item_container_button_group
		item.expand_icon = true
		item.custom_minimum_size = Vector2(64,64)
		item.set_meta("item_name", key)
		item.set_meta("item_type", c[1])
		item_container.add_child.call_deferred(item)
	# sidepanel for selection
	
func clear_self():
	#remove_control_from_docks(button) # leads to errors even with call_deferred
	# button.free()
	remove_control_from_container(CONTAINER_SPATIAL_EDITOR_MENU, cell_label)
	
	remove_control_from_container(CONTAINER_SPATIAL_EDITOR_SIDE_LEFT, left_container)
	
	preview.free()
	preview_plane.free()
	preview = null
	preview_plane = null
	left_container.free()
	left_container = null
	cell_label.free()
	cell_label = null
	in_valid_state = false

func _exit_tree():
	#print("clear self")
	clear_self()

var selected := []

func get_selected() -> Puzzle_Editor:
	if selected.size() <= 0:
		return null
	if selected[0] is Puzzle_Editor:
		return selected[0]
	else:
		return null

func place_preview() -> void:
	var plane := Plane(Vector3.UP)
	plane.d = preview.global_position.y
	# plane.d = 0.
	# plane.y = preview.global_position.y
	
	var mpos := viewport.get_mouse_position()
	var dir := camera.project_ray_normal(mpos)
	
	var point = plane.intersects_ray(camera.global_position, dir)	
	if point:
		var spoint := point as Vector3 + settings.CUBE_SIZE_XZ/2 
		var s := spoint.snapped(Vector3(1., 0., 1.0)) as Vector3
		s -= Vector3(1., 0., 1.)
		cursor_cell = Vector3i(s.x, plane_level, s.z)
		s += settings.CUBE_SIZE_XZ/2.
		

		preview.global_position.x = s.x
		preview.global_position.z = s.z
	
	
func _process(_delta: float):
	if !Engine.is_editor_hint(): return
	# godot editor checking
	editor = get_selected()
	var sel := editor
	selected = EditorInterface.get_selection().get_selected_nodes()
	var just_selected := !sel && get_selected()
	var just_unselected := sel && !get_selected()

	if just_unselected:
		clear_self()
		#print("just_unselected")
		
		
	if just_selected:
		make_self()

	# our editor
	if !in_valid_state: return
	cell_label.text = str(cursor_cell)
	# if !preview: return
	if editor:
		place_preview()
		editor.set_meta("_edit_lock_", true)

	var button := item_container_button_group.get_pressed_button()
	if button:
		var iname = button.get_meta("item_name")
		var itype = button.get_meta("item_type")
		selected_item = itype
	else:
		selected_item = null


func _do_place_object():
	pass
func _undo_place_object(p: Puzzle_Object):
	# @todo?
	# right now for the editor big/small is being ignored and
	# instead we just go by the existence of the cell

	# editor.remove_from_cell(p)
	# this will leak the other objects
	editor.remove_cell(p.cell)
	p.queue_free()
	

# safe variant
# type: Puzzle_Object.Type but it should be more generalized here since this is inside the addon
func place_object(cell: Vector3i, type):	
	if !editor: return
	
	if editor.get_cell(cell):
		# printerr("Object is already placed at " + str(cell))
		return
	
	
	var p = settings.load_object(type)
	if !p:
		printerr("type not implemented")
		return
	

	editor.add_child(p)
	var own := EditorInterface.get_edited_scene_root()
	# This binds it to the current scene and makes it visible for editing and saving
	p.set_owner(own)
	p.global_position = Vector3(cell) + settings.CUBE_SIZE_XZ/2.
	editor.set_cell(cell, p)
	
	print("place object at " + str(cell), " with ", type)
	var ur := get_undo_redo()
	ur.create_action("Object placement")
	ur.add_undo_method(self, "_undo_place_object", p)
	ur.commit_action()

# save variant
func remove_object(cell: Vector3i):
	var p := editor.get_cell(cell)
	if !p:
		return
	editor.remove_cell(cell)
	p.free_objects()
	

func clear_objects():
	if !editor: return
	editor.clear()
	

		
# activates _forwards_*		
func _handles(obj: Object) -> bool:
	if obj is Puzzle_Editor:
		return true
	return false

""" func _forward_canvas_gui_input(event: InputEvent) -> bool:
	return true """
# restriced to InputEventKey see is_echo doc
func just_pressed(event: InputEventKey) -> bool:
	return event.is_pressed() && !event.is_echo()
var mouse_keys := {
	"mouse_l": false,
	"mouse_r": false,
}
func _forward_3d_gui_input(camera: Camera3D, event: InputEvent):
	var ret := AFTER_GUI_INPUT_PASS 
	if !Engine.is_editor_hint() || !preview_plane: return ret

	#print("forward", event)
	# print(preview.global_position)
	preview_plane.visible = true
	preview_plane.global_position.y = -0.5 + float(plane_level)
	preview.global_position.y = settings.CUBE_LEN * float(plane_level)
	if event is InputEventKey:
		if just_pressed(event) && event.keycode == KEY_Q:
			plane_level += 1
			# get_viewport().set_input_as_handled()
			# preview_plane.global_position.y += CUBE_LEN						
			# preview.global_position.y += CUBE_LEN
			ret = AFTER_GUI_INPUT_STOP
		elif just_pressed(event) && event.keycode == KEY_E:
			plane_level -= 1
			# preview_plane.global_position.y -= CUBE_LEN
			# preview.global_position.y -= CUBE_LEN
			ret = AFTER_GUI_INPUT_STOP
		elif just_pressed(event) && event.keycode == KEY_P:
			print("clear")
			clear_objects()
			ret = AFTER_GUI_INPUT_STOP
	elif event is InputEventMouse:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT:				
				if event.is_pressed():
					mouse_keys.mouse_l = true					
				elif event.is_released():
					mouse_keys.mouse_l = false
				ret = AFTER_GUI_INPUT_STOP
			elif event.button_index == MOUSE_BUTTON_RIGHT:
				if event.is_pressed():
					mouse_keys.mouse_r = true					
				elif event.is_released():
					mouse_keys.mouse_r = false
				ret = AFTER_GUI_INPUT_STOP
	
	if mouse_keys.mouse_l:
		if selected_item:
			place_object(cursor_cell, selected_item)
		else:
			printerr("no item selected for placement")
		
	elif mouse_keys.mouse_r:	
		remove_object(cursor_cell)
		
	return ret


#func _has_main_screen() -> bool:
#	return true
