extends Node3D
class_name Terrain

var block_scene = preload("res://block.tscn")

@onready var physics_checker: PhysicsChecker = $PhysicsChecker

var _blocks: Dictionary[int, Dictionary]
var layer_indicies: Array[int]: 
	get(): 
		var indicies = _blocks.keys()
		indicies.sort_custom(func(a, b): return a > b)
		return indicies
func set_block_by_layer(layer: int, pos2d: Vector2i, block: Block) -> void:
	if block != null:
		if not _blocks.has(layer):
			_blocks[layer] = {}
		_blocks[layer][pos2d] = block
	else:
		_blocks[layer].erase(pos2d)
		if _blocks[layer].is_empty():
			_blocks.erase(layer)
func get_block_by_layer(layer: int, pos2d: Vector2i) -> Block:
	return _blocks[layer][pos2d]
func set_block(pos3d: Vector3i, block: Block) -> void:
	var pos2d: Vector2i = Vector2i(pos3d.x, pos3d.z)
	set_block_by_layer(pos3d.y, pos2d, block)
func get_block(pos3d: Vector3i) -> Block:
	var pos2d: Vector2i = Vector2i(pos3d.x, pos3d.z)
	return get_block_by_layer(pos3d.y, pos2d)
func layer_exists(layer: int) -> bool:
	return _blocks.has(layer)
func get_block_positions_in_layer(layer: int) -> Dictionary[Vector2i, Block]:
	return _blocks[layer]
func block_exists_by_layer(layer: int, pos2d: Vector2i) -> bool:
	return _blocks[layer].has(pos2d)
func block_exists(pos3d: Vector3i) -> bool:
	return block_exists_by_layer(pos3d.y, Vector2i(pos3d.x, pos3d.z))

func place_block(pos: Vector3i, facing: Block.Facing, properties: BlockProperties) -> void:
	var new_block: Block = block_scene.instantiate()
	set_block(pos, new_block)
	new_block.position = Vector3(pos)
	new_block.properties = properties
	add_child(new_block)
	new_block.facing = facing
	new_block.player_interacted_primary.connect(_on_block_player_interacted_primary.bind(pos))
	new_block.player_interacted_secondary.connect(_on_block_player_interacted_secondary.bind(pos))
	
	physics_checker.check()

func remove_block(pos: Vector3i) -> void:
	var block = get_block(pos)
	set_block(pos, null)
	remove_child(block)
	
	physics_checker.check()

func _on_block_player_interacted_primary(grid_position: Vector3i) -> void:
	remove_block(grid_position)

func _on_block_player_interacted_secondary(direction: Vector3i, properties: BlockProperties, grid_position: Vector3i) -> void:
	if direction.length() == 1:
		var place_position = grid_position + direction
		var place_facing: Block.Facing
		match direction:
			Vector3i(1, 0, 0): place_facing = Block.Facing.XPlus
			Vector3i(-1, 0, 0): place_facing = Block.Facing.XMinus
			Vector3i(0, 1, 0): place_facing = Block.Facing.YPlus
			Vector3i(0, -1, 0): place_facing = Block.Facing.YMinus
			Vector3i(0, 0, 1): place_facing = Block.Facing.ZPlus
			Vector3i(0, 0, -1): place_facing = Block.Facing.ZMinus
		place_block(place_position, place_facing, properties)

func _ready() -> void:
	place_block(Vector3i(0, 0, 0), Block.Facing.YPlus, preload("res://resources/magic_block_properties.tres"))
