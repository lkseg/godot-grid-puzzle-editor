@tool
extends Node3D

@export var value := 1: set = set_value
@export var id: int

var active := true
# usable => active
var usable := true

@onready var area := $area

func _validate_property(v: Dictionary):	
	if v.name in ["id"]:
		v.usage = PROPERTY_USAGE_NO_EDITOR
	


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	area.body_entered.connect(_on_body_entered)
	$label.text = str(value)
	get_parent().pawns[id] = self

func _physics_process(delta: float)	-> void:
	if Engine.is_editor_hint():
		return
	if area.has_overlapping_bodies():
		assert(area.get_overlapping_bodies().size()==1)
		if usable && get_parent()._on_entered_object(self):	
			set_active(false)
func get_model() -> MeshInstance3D:
	return $area/model


func set_usable(b := true) -> void:
	if !is_inside_tree(): return
	if !active && b:
		return
	usable = b
	var p := $particles
	p.visible = usable

func set_active(b := true) -> void:
	if !is_inside_tree(): return
	var model := get_model()
	active = b
	if b:				
		model.material_override.albedo_color = Color("e3ba00")
	else:
		model.material_override.albedo_color = Color(0,0,0,1)
		set_usable(false)


func _on_body_entered(node: Node3D) -> void:
	return

func set_value(r: int) -> void:
	value = r
	var label := get_node_or_null("label") as Label3D
	if label:
		label.text = str(value)



