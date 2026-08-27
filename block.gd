extends StaticBody3D
class_name Block

signal player_interacted_primary
signal player_interacted_secondary(direction: Vector3i, selected_properties: BlockProperties)

enum Facing {
	XPlus, XMinus, YPlus, YMinus, ZPlus, ZMinus
}

@onready var labels: Array[Label3D] = [$Labels/Label3D, $Labels/Label3D2, $Labels/Label3D3, $Labels/Label3D4, $Labels/Label3D5, $Labels/Label3D6]
@onready var meshes: Node3D = $Meshes
@onready var face_meshes: Dictionary[Facing, MeshInstance3D] = {
	Facing.XPlus: $"Meshes/X+Mesh", 
	Facing.XMinus: $"Meshes/X-Mesh", 
	Facing.YPlus: $"Meshes/Y+Mesh", 
	Facing.YMinus: $"Meshes/Y-Mesh", 
	Facing.ZPlus: $"Meshes/Z+Mesh", 
	Facing.ZMinus: $"Meshes/Z-Mesh"
}

var properties: BlockProperties:
	set(new_properties):
		properties = new_properties
		if properties is MagicBlockProperties:
			state = BlockState.new()
		elif properties is BuddyBlockProperties:
			state = BuddyBlockState.new()
		elif properties is BeamBlockProperties:
			state = BeamBlockState.new()
		elif properties is PlatformBlockProperties:
			state = BlockState.new()
var facing: Facing:
	set(new_facing):
		if meshes == null: return
		facing = new_facing
		match facing:
			Facing.XPlus:
				meshes.rotation_degrees = Vector3(0, 0, 0)
			Facing.XMinus:
				meshes.rotation_degrees = Vector3(0, 180, 0)
			Facing.YPlus:
				meshes.rotation_degrees = Vector3(0, 0, 90)
			Facing.YMinus:
				meshes.rotation_degrees = Vector3(0, 0, -90)
			Facing.ZPlus:
				meshes.rotation_degrees = Vector3(0, -90, 0)
			Facing.ZMinus:
				meshes.rotation_degrees = Vector3(0, 90, 0)
var state: BlockState

func update_text() -> void:
	var text: String = ""
	
	text += "Supports\n" + str(snappedf(state.supported_weight, 0.01)) + " / "
	if properties is BuddyBlockProperties:
		text += str(snappedf(properties.base_strength + properties.strength_per_buddy * state.buddy_count, 0.01)) + "\n"
	elif properties is MagicBlockProperties:
		text += "Inf\n"
	else:
		text += str(snappedf(properties.base_strength, 0.01)) + "\n"
	if state.marked_to_fall:
		text += "Fall\n"
	if state.marked_to_be_crushed:
		text += "Crush\n"
	
	for label in labels:
		label.text = text

func interact_primary() -> void:
	player_interacted_primary.emit()

func interact_secondary(direction: Vector3i, selected_properties: BlockProperties) -> void:
	player_interacted_secondary.emit(direction, selected_properties)

func make_selected() -> void:
	for face in Facing.values():
		face_meshes[face].set_surface_override_material(0, properties.selected_materials[face])

func make_unselected() -> void:
	for face in Facing.values():
		face_meshes[face].set_surface_override_material(0, properties.materials[face])

func _ready() -> void:
	make_unselected()
