extends Node

#var cursor: Control = get_tree().current_scene.find_child("cursor")


func get_cursor_position() -> Vector2:
	if Config.use_custom_cursor:
		assert(false)
		return Vector2(-1,-1)
	else:
		return get_viewport().get_mouse_position()

	

static func default_ray_param() -> PhysicsRayQueryParameters3D:
	var ray_param := PhysicsRayQueryParameters3D.new()	
	ray_param.collide_with_areas = true
	ray_param.collide_with_bodies = true
	ray_param.collision_mask = 0xFFFFFFFF
	ray_param.exclude = []
	ray_param.hit_back_faces = true
	ray_param.hit_from_inside = false
	return ray_param

static func get_movement_input_3d() -> Vector3:
	var x_input=Input.get_action_strength("right")-Input.get_action_strength("left")
	var z_input=Input.get_action_strength("back")-Input.get_action_strength("forward")
	return Vector3(x_input, 0, z_input)

static func get_movement_input_2d() -> Vector2: 
	var x_input=Input.get_action_strength("right")-Input.get_action_strength("left")
	var z_input=Input.get_action_strength("back")-Input.get_action_strength("forward")
	return Vector2(x_input,z_input)

static func get_movement_input() -> Vector2:
	var x_input=Input.get_action_strength("right")-Input.get_action_strength("left")
	var z_input=Input.get_action_strength("forward")-Input.get_action_strength("back")
	return Vector2(x_input,z_input)

static func add_to(_node,_parent):
	_parent.add_child(_node)
	return _node


static func align_basis_by(basis:Basis, v: Vector3) -> Basis:
	basis.y = v
	basis.x = -basis.z.cross(v)
	return basis.orthonormalized()
	
static func cursor_cast_ray(camera: Camera3D, param := default_ray_param()) -> Dictionary:
	var pos := camera.get_viewport().get_mouse_position()
	#var param := default_ray_param()
	param.from = camera.project_ray_origin(pos)
	param.to = param.from + camera.project_ray_normal(pos) * 1000
	return camera.get_world_3d().direct_space_state.intersect_ray(param)

static func cursor_cast_box(camera: Camera3D, param := default_ray_param()) -> Dictionary:
	var pos := camera.get_viewport().get_mouse_position()

	param.from = camera.project_ray_origin(pos)
	param.to = param.from + camera.project_ray_normal(pos) * 1000
	return camera.get_world_3d().direct_space_state.intersect_ray(param)
	

# # casts ray from e's position down
# func cast_ray_down(e: Node3D) -> Dictionary:
# 	ray_param.from = e.global_position
# 	ray_param.to = ray_param.from + Vector3.DOWN * 1000
# 	return e.get_world_3d().direct_space_state.intersect_ray(ray_param)


# -y is up; -x is left
static func direction_from_camera(camera: Camera3D, v: Vector2) -> Vector3:
	var b := camera.global_transform.basis

	var z := Vector2(b.z.x, b.z.z).normalized()
	var x := Vector2(b.x.x, b.x.z).normalized()
	return as_vec3(v.x*x + v.y*z)

static func snap_camera_basis(camera: Camera3D) -> Array[Vector3]:
	var b := camera.transform.basis

	var z := -Vector2(b.z.x, b.z.z).normalized()
	var x := Vector2(b.x.x, b.x.z).normalized()

	var f := vector2_snap(z, Vector2.UP)
	var r := vector2_snap(x, Vector2.RIGHT)
	return [Vector3(f.x, 0, f.y), Vector3(r.x, 0, r.y)]

static func vector2_snap(v: Vector2, axis: Vector2, eps := PI/4.0) -> Vector2:
	assert(v.is_normalized() && axis.is_normalized())
	var angle := atan2(v.cross(axis), v.dot(axis))
	if abs(angle) < eps:
		return v.rotated(angle)
	if PI - abs(angle) < eps:
		return v.rotated(-(PI-angle))
	if angle >= 0:
		return v.rotated(angle - PI/2)
	return v.rotated(PI/2 + angle)

static func logn(val, n: float) -> float:
	return log(val)/log(n)

static func get_script_name(obj) -> String:
	return obj.get_script().get_path().get_file()

static func add_script(parent: Node, script: GDScript) -> Variant:	
	var r = script.new()
	parent.add_child(r)
	return r

static func add_scene(parent: Node, scene: PackedScene) -> Variant:	
	var r = scene.instantiate()
	parent.add_child(r)
	return r	

static func as_vec3(v: Vector2) -> Vector3:
	return Vector3(v.x, 0.0, v.y)


static func load_all_dir_threaded(dc: Dictionary, root: StringName, dirs: Array[StringName], attach_prefix: Array[StringName] = [], suffix: String = "", is_resource := false) -> Dictionary:
	assert(dirs.size() == attach_prefix.size() || attach_prefix.size() == 0)
	var names: Array[PackedStringArray]
	for dir in dirs:
		var file_names := DirAccess.get_files_at(root+dir)
		if is_resource:
			var i := 0
			# for loops don't update .size() ...
			while i < file_names.size():
				var _name := file_names[i]
				if _name.contains(".import"):
					file_names.remove_at(i)
					i -= 1
				i += 1

		names.append(file_names)

	for i in names.size():
			var file_names := names[i]
			var dir := dirs[i]
			for _name in file_names:
				# why is this even a thing?
				# remap for tscn and import for png
				var s := _name.trim_suffix(".remap").trim_suffix(".import")
				ResourceLoader.load_threaded_request(root+dir+s, "", true, ResourceLoader.CACHE_MODE_IGNORE)
			
	for i in dirs.size():
		var file_names := names[i]
		var dir := dirs[i]
		var prefix := attach_prefix[i] if attach_prefix.size() > 0 else "" as StringName
		for _name in file_names:
			var s := _name.trim_suffix(".remap").trim_suffix(".import")
			var scene := ResourceLoader.load_threaded_get(root+dir+s)
			var a_name := prefix + s.trim_suffix(suffix)
			dc[a_name] = scene
			print("load: ", a_name, scene)
	return dc
	


# func lock_cursor() -> void:
# 	cursor.lock()
	
# func unlock_cursor() -> void:
# 	cursor.unlock()

# versions that were used in camera for native cursor (not custom)
# func lock_cursor() -> void:
# 	cursor_anchor = xx.get_cursor_position()
# 	Input.mouse_mode = Input.MouseMode.MOUSE_MODE_HIDDEN
# func unlock_cursor() -> void:
# 	Input.warp_mouse(cursor_anchor)
# 	Input.mouse_mode = Input.MOUSE_MODE_CONFINED # VISIBLE


# static func snap_2(Vector2)
