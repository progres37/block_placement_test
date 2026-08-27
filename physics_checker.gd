extends Node
class_name PhysicsChecker

@export var terrain : Terrain

func check() -> void:
	for layer in terrain.layer_indicies:
		for pos2d in terrain.get_block_positions_in_layer(layer):
			var block: Block = terrain.get_block_by_layer(layer, pos2d)
			block.state.reset()
	
	for layer in terrain.layer_indicies:
		for pos2d in terrain.get_block_positions_in_layer(layer):
			var block: Block = terrain.get_block_by_layer(layer, pos2d)
			
			if block.properties is MagicBlockProperties:
				pass
			
			elif block.properties is BuddyBlockProperties:
				if not terrain.layer_exists(layer - 1) or not terrain.block_exists_by_layer(layer - 1, pos2d):
					block.state.marked_to_fall = true
				else:
					for potential_buddy_pos in [pos2d + Vector2i(1, 0), pos2d + Vector2i(-1, 0), pos2d + Vector2i(0, 1), pos2d + Vector2i(0, -1)]:
						if terrain.block_exists_by_layer(layer, potential_buddy_pos):
							block.state.buddy_count += 1
					var effective_strength: float = block.properties.base_strength + block.properties.strength_per_buddy * block.state.buddy_count
					if block.state.supported_weight > effective_strength:
						block.state.marked_to_be_crushed = true
					terrain.get_block_by_layer(layer - 1, pos2d).state.supported_weight += block.state.supported_weight + block.properties.weight
			
			elif block.properties is BeamBlockProperties:
				if not terrain.layer_exists(layer - 1):
					block.state.marked_to_fall = true
				elif block.facing == Block.Facing.YPlus or block.facing == Block.Facing.YMinus:
					if not terrain.block_exists_by_layer(layer - 1, pos2d):
						block.state.marked_to_fall = true
					elif block.state.supported_weight > block.properties.base_strength:
						block.state.marked_to_be_crushed = true
						terrain.get_block_by_layer(layer - 1, pos2d).state.supported_weight += block.state.supported_weight + block.properties.weight
					else:
						terrain.get_block_by_layer(layer - 1, pos2d).state.supported_weight += block.state.supported_weight + block.properties.weight
				else:
					if block.state.beam == null:
						var beam: Beam = Beam.new()
						block.state.beam = beam
						if terrain.block_exists_by_layer(layer - 1, pos2d):
							beam.support_positions.append(pos2d)
						
						var axis_step: Vector2i
						if block.facing == Block.Facing.XPlus or block.facing == Block.Facing.XMinus:
							axis_step = Vector2i(1, 0)
							beam.acceptable_facings = [Block.Facing.XPlus, Block.Facing.XMinus]
						elif block.facing == Block.Facing.ZPlus or block.facing == Block.Facing.ZMinus:
							axis_step = Vector2i(0, 1)
							beam.acceptable_facings = [Block.Facing.ZPlus, Block.Facing.ZMinus]
						
						var axis_pos: Vector2i = pos2d
						while true:
							axis_pos -= axis_step
							if not terrain.block_exists_by_layer(layer, axis_pos):
								break
							var axis_block: Block = terrain.get_block_by_layer(layer, axis_pos)
							if not axis_block.properties is BeamBlockProperties or not beam.acceptable_facings.has(axis_block.facing):
								break
							axis_block.state.beam = beam
							if terrain.block_exists_by_layer(layer - 1, axis_pos):
								beam.support_positions.append(axis_pos)
						axis_pos = pos2d
						while true:
							axis_pos += axis_step
							if not terrain.block_exists_by_layer(layer, axis_pos):
								break
							var axis_block: Block = terrain.get_block_by_layer(layer, axis_pos)
							if not axis_block.properties is BeamBlockProperties or not beam.acceptable_facings.has(axis_block.facing):
								break
							axis_block.state.beam = beam
							if terrain.block_exists_by_layer(layer - 1, axis_pos):
								beam.support_positions.append(axis_pos)
					if block.state.beam.support_positions.size() == 0:
						block.state.marked_to_fall = true
					elif block.state.beam.get_support_distance(pos2d) > block.properties.max_support_distance:
						block.state.marked_to_fall = true
					else:
						if block.state.supported_weight > block.properties.base_strength:
							block.state.marked_to_be_crushed = true
						var support_count: float = block.state.beam.support_positions.size()
						for support_pos in block.state.beam.support_positions:
							terrain.get_block_by_layer(layer - 1, support_pos).state.supported_weight += (block.state.supported_weight + block.properties.weight) / support_count
			
			elif block.properties is PlatformBlockProperties:
				pass
	
	for layer in terrain.layer_indicies:
		for pos2d in terrain.get_block_positions_in_layer(layer):
			var block: Block = terrain.get_block_by_layer(layer, pos2d)
			block.update_text()

func _ready() -> void:
	pass
