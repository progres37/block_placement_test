extends Resource
class_name BlockProperties

@export var name: String
@export var material: StandardMaterial3D:
	set(val):
		material = val
		if val != null:
			selected_material.copy_from_resource(val)
			selected_material.albedo_color *= 0.75
var selected_material: StandardMaterial3D = StandardMaterial3D.new()
@export_group("Physical properties")
@export var immovable: bool
@export var weight: float
@export var strength: float
@export var sideways_transfer_predisposition: float
@export var sideways_transfer_limit: float
