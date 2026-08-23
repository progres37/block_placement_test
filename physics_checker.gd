extends Node
class_name PhysicsChecker

@export var terrain : Terrain

# if there is untransferred weight, block falls
# if supported weight is greater than strangth, block is crushed

func check() -> void:
	var block_position_layers: Dictionary[int, Array] = {}
	var min_layer_idx: int = terrain.blocks.keys()[0].y
	var max_layer_idx: int = terrain.blocks.keys()[0].y
	for block_position in terrain.blocks.keys():
		if not block_position_layers.has(block_position.y):
			block_position_layers[block_position.y] = []
		block_position_layers[block_position.y].append(block_position)
		if block_position.y > max_layer_idx:
			max_layer_idx = block_position.y
		elif block_position.y < min_layer_idx:
			min_layer_idx = block_position.y
		
		var block = terrain.blocks[block_position]
		block.supported_upward_weight = 0
		block.supported_sideways_weight = 0
		block.sideways_transferred_weight = 0
		block.is_sitting = terrain.blocks.has(block_position + Vector3i(0, -1, 0)) or block.properties.immovable
		block.marked_for_fall = false
		block.marked_for_crush = false
	
	for layer_idx in range(max_layer_idx, min_layer_idx - 1, -1):
		if not block_position_layers.has(layer_idx):
			continue
		
		# sideways transfer loop
		for position in block_position_layers[layer_idx]:
			var block = terrain.blocks[position]
			if block.properties.immovable:
				continue
			var positions_for_transfer: Array[Vector3i]
			var potential_positions = [position + Vector3i(1, 0, 0), position + Vector3i(0, 0, 1), position + Vector3i(-1, 0, 0), position + Vector3i(0, 0, -1)]
			for side_pos in potential_positions:
				if terrain.blocks.has(side_pos) and terrain.blocks[side_pos].is_sitting:
					positions_for_transfer.append(side_pos)
			var side_count = positions_for_transfer.size()
			if side_count == 0:
				if not block.is_sitting:
					block.marked_for_fall = true
				continue
			var max_weight_to_transfer: float = block.properties.weight + block.supported_upward_weight
			if not block.is_sitting:
				if max_weight_to_transfer > block.properties.sideways_transfer_limit * side_count:
					block.marked_for_fall = true
					block.sideways_transferred_weight = 0
				else:
					block.sideways_transferred_weight = max_weight_to_transfer
			else:
				var weight_to_transfer_fraction = float(side_count) * block.properties.sideways_transfer_predisposition / (block.properties.sideways_transfer_predisposition * 4.0 + 1.0)
				block.sideways_transferred_weight = clampf(max_weight_to_transfer * weight_to_transfer_fraction, 0, block.properties.sideways_transfer_limit * side_count)
			for side_pos in positions_for_transfer:
				terrain.blocks[side_pos].supported_sideways_weight += block.sideways_transferred_weight / side_count
		
		# downward transfer loop
		for position in block_position_layers[layer_idx]:
			var block = terrain.blocks[position]
			if block.properties.immovable:
				continue
			if not block.is_sitting:
				continue
			var supported_weight = block.supported_upward_weight + block.supported_sideways_weight - block.sideways_transferred_weight
			if supported_weight > block.properties.strength + 1e-6:
				block.marked_for_crush = true
			var weight_to_transfer = supported_weight + block.properties.weight
			terrain.blocks[position + Vector3i(0, -1, 0)].supported_upward_weight += weight_to_transfer
		
		# visual update loop
		for position in block_position_layers[layer_idx]:
			terrain.blocks[position].update_text()

func _ready() -> void:
	pass
