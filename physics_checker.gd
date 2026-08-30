extends Node
class_name PhysicsChecker

@export var terrain : Terrain

func check() -> void:
	for layer: int in terrain.layer_indicies:
		for pos2d: Vector2i in terrain.get_block_positions_in_layer(layer):
			var block: Block = terrain.get_block_by_layer(layer, pos2d)
			block.state.reset()
	
	for layer: int in terrain.layer_indicies:
		for pos2d: Vector2i in terrain.get_block_positions_in_layer(layer):
			var block: Block = terrain.get_block_by_layer(layer, pos2d)
			if block.properties is BeamBlockProperties and (block.facing == Block.Facing.YPlus or block.facing == Block.Facing.YMinus):
				var properties: BeamBlockProperties = block.properties
				
				if properties.buddy_block_reach <= 0:
					continue
				var buddy_block_positions_by_distance: Dictionary[int, Array] = {1: []}
				
				for side_pos: Vector2i in [pos2d + Vector2i(1, 0), pos2d + Vector2i(-1, 0), pos2d + Vector2i(0, 1), pos2d + Vector2i(0, -1)]:
					if not terrain.block_exists_by_layer(layer, side_pos):
						continue
					var side_block: Block = terrain.get_block_by_layer(layer, side_pos)
					if not side_block.properties is BuddyBlockProperties:
						continue
					buddy_block_positions_by_distance[1].append(side_pos)
					var buddy_block_state: BuddyBlockState = side_block.state
					if not buddy_block_state.beam_present:
						buddy_block_state.beam_present = true
				
				for distance: int in range(1, block.properties.buddy_block_reach + 1):
					buddy_block_positions_by_distance[distance + 1] = []
					for buddy_block_pos: Vector2i in buddy_block_positions_by_distance[distance]:
						var buddy_block_state: BuddyBlockState = terrain.get_block_by_layer(layer, buddy_block_pos).state
						if not buddy_block_state.beam_present:
							buddy_block_state.beam_present = true
						for side_pos: Vector2i in [buddy_block_pos + Vector2i(1, 0), buddy_block_pos + Vector2i(-1, 0), buddy_block_pos + Vector2i(0, 1), buddy_block_pos + Vector2i(0, -1)]:
							if not terrain.block_exists_by_layer(layer, side_pos):
								continue
							var side_block: Block = terrain.get_block_by_layer(layer, side_pos)
							if not side_block.properties is BuddyBlockProperties:
								continue
							buddy_block_positions_by_distance[distance + 1].append(side_pos)
						
	
	for layer: int in terrain.layer_indicies:
		for pos2d: Vector2i in terrain.get_block_positions_in_layer(layer):
			var block: Block = terrain.get_block_by_layer(layer, pos2d)
			
			if block.properties is MagicBlockProperties:
				pass
			
			elif block.properties is BuddyBlockProperties:
				var properties: BuddyBlockProperties = block.properties
				var state: BuddyBlockState = block.state
				if not terrain.layer_exists(layer - 1) or not terrain.block_exists_by_layer(layer - 1, pos2d):
					state.marked_to_fall = true
				else:
					for potential_buddy_pos: Vector2i in [pos2d + Vector2i(1, 0), pos2d + Vector2i(-1, 0), pos2d + Vector2i(0, 1), pos2d + Vector2i(0, -1)]:
						if terrain.block_exists_by_layer(layer, potential_buddy_pos):
							state.buddy_count += 1
					state.effective_strength = (properties.base_strength + properties.strength_per_buddy * state.buddy_count)
					if state.beam_present:
						state.effective_strength += properties.beam_presence_strength
					if state.supported_weight > state.effective_strength + 1e-6:
						state.marked_to_be_crushed = true
					terrain.get_block_by_layer(layer - 1, pos2d).state.supported_weight += state.supported_weight + properties.weight
			
			elif block.properties is BeamBlockProperties:
				var properties: BeamBlockProperties = block.properties
				var state: BeamBlockState = block.state
				if not terrain.layer_exists(layer - 1):
					state.marked_to_fall = true
				elif block.facing == Block.Facing.YPlus or block.facing == Block.Facing.YMinus:
					if not terrain.block_exists_by_layer(layer - 1, pos2d):
						state.marked_to_fall = true
					elif state.supported_weight > properties.base_strength + 1e-6:
						state.marked_to_be_crushed = true
						terrain.get_block_by_layer(layer - 1, pos2d).state.supported_weight += state.supported_weight + properties.weight
					else:
						terrain.get_block_by_layer(layer - 1, pos2d).state.supported_weight += state.supported_weight + properties.weight
				else:
					if state.beam == null:
						var beam: Beam = Beam.new()
						state.beam = beam
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
							if not axis_block.properties is BeamBlockProperties or not properties == axis_block.properties:
								break
							if not beam.acceptable_facings.has(axis_block.facing):
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
							if not axis_block.properties is BeamBlockProperties or not properties == axis_block.properties:
								break
							if not beam.acceptable_facings.has(axis_block.facing):
								break
							axis_block.state.beam = beam
							if terrain.block_exists_by_layer(layer - 1, axis_pos):
								beam.support_positions.append(axis_pos)
					if state.beam.support_positions.size() == 0:
						state.marked_to_fall = true
					elif state.beam.get_support_distance(pos2d) > properties.max_support_distance:
						state.marked_to_fall = true
					else:
						if state.supported_weight > properties.base_strength + 1e-6:
							state.marked_to_be_crushed = true
						var support_count: float = state.beam.support_positions.size()
						for support_pos: Vector2i in state.beam.support_positions:
							terrain.get_block_by_layer(layer - 1, support_pos).state.supported_weight += (state.supported_weight + properties.weight) / support_count
			
			elif block.properties is PlatformBlockProperties:
				pass
	
	for layer: int in terrain.layer_indicies:
		for pos2d: Vector2i in terrain.get_block_positions_in_layer(layer):
			var block: Block = terrain.get_block_by_layer(layer, pos2d)
			block.update_text()

func _ready() -> void:
	pass
