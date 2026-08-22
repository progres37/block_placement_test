extends StaticBody3D
class_name Block

signal player_interacted_primary()
signal player_interacted_secondary(direction: Vector3i, selected_properties: BlockProperties)
signal player_began_look
signal player_ended_look

@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D
@onready var labels: Array[Label3D] = [
	$MeshInstance3D/Label3D,
	$MeshInstance3D/Label3D2,
	$MeshInstance3D/Label3D3,
	$MeshInstance3D/Label3D4,
	$MeshInstance3D/Label3D5,
	$MeshInstance3D/Label3D6
]

@export var properties: BlockProperties
var supported_upward_weight: float = 0
var supported_sideways_weight: float = 0
var sideways_transferred_weight: float = 0
var is_sitting: bool = false
var marked_for_fall: bool = false
var marked_for_crush: bool = false

func update_text() -> void:
	var text: String = ""
	text += " V " + str(supported_upward_weight) + "\n"
	text += ">< " + str(supported_sideways_weight) + "\n"
	text += "<> " + str(sideways_transferred_weight) + "\n"
	if marked_for_fall:
		text += "fall\n"
	if marked_for_crush:
		text += "crush\n"
	
	for label in labels:
		label.text = text

func _on_player_began_look() -> void:
	mesh_instance_3d.set_surface_override_material(0, properties.selected_material)

func _on_player_ended_look() -> void:
	mesh_instance_3d.set_surface_override_material(0, properties.material)

func _ready() -> void:
	mesh_instance_3d.set_surface_override_material(0, properties.material)
