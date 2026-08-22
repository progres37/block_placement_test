extends Node3D
class_name Terrain

var block_scene = preload("res://block.tscn")

@onready var physics_checker: PhysicsChecker = $PhysicsChecker

var blocks: Dictionary[Vector3i, Block]

func place_block(grid_position: Vector3i, properties: BlockProperties) -> void:
	var new_block: Block = block_scene.instantiate()
	blocks[grid_position] = new_block
	new_block.position = Vector3(grid_position)
	new_block.properties = properties
	add_child(new_block)
	new_block.player_interacted_primary.connect(_on_block_player_interacted_primary.bind(grid_position))
	new_block.player_interacted_secondary.connect(_on_block_player_interacted_secondary.bind(grid_position))

func remove_block(grid_position: Vector3i) -> void:
	var block = blocks[grid_position]
	blocks.erase(grid_position)
	remove_child(block)

func _on_block_player_interacted_primary(grid_position: Vector3i) -> void:
	remove_block(grid_position)
	physics_checker.check()

func _on_block_player_interacted_secondary(direction: Vector3i, properties: BlockProperties, grid_position: Vector3i) -> void:
	if direction.length() == 1:
		var place_position = grid_position + direction
		place_block(place_position, properties)
		physics_checker.check()

func _ready() -> void:
	place_block(Vector3i(0,0,0), preload("res://block_properties/support_block_properties.tres"))
	place_block(Vector3i(1,0,0), preload("res://block_properties/support_block_properties.tres"))
