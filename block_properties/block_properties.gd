@abstract
extends Resource
class_name BlockProperties

enum Facing {
	XPlus, XMinus, YPlus, YMinus, ZPlus, ZMinus
}

@export var name: String
@export var materials: Dictionary[Facing, StandardMaterial3D] = {
	Facing.XPlus: null, Facing.XMinus: null, Facing.YPlus: null, Facing.YMinus: null, Facing.ZPlus: null, Facing.ZMinus: null
}:
	set(val):
		materials = val
		update_selected_materials()
@export var weight: float
@export var base_strength: float

var selected_materials: Dictionary[Facing, StandardMaterial3D]

func update_selected_materials() -> void:
	for block_face in Facing.values():
		selected_materials[block_face] = StandardMaterial3D.new()
		selected_materials[block_face].copy_from_resource(materials[block_face])
		selected_materials[block_face].albedo_color *= 0.75

func _init() -> void:
	for block_face in Facing.values():
		materials[block_face] = StandardMaterial3D.new()
