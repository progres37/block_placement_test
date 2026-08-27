extends Object
class_name Beam

var support_positions: Array[Vector2i] = []
var acceptable_facings: Array[Block.Facing] = []

func get_support_distance(pos2d: Vector2i) -> int:
	var min_distance: int
	var first_support: bool = true
	for support_pos2d in support_positions:
		var distance: int
		if acceptable_facings.has(Block.Facing.XPlus):
			distance = absi(pos2d.x - support_pos2d.x)
		else:
			distance = absi(pos2d.y - support_pos2d.y)
		if first_support:
			first_support = false
			min_distance = distance
		else:
			if distance < min_distance:
				min_distance = distance
	return min_distance
