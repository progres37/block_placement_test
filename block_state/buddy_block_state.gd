extends BlockState
class_name BuddyBlockState

var buddy_count: int
var beam_present: bool
var effective_strength: float

func reset() -> void:
	super.reset()
	buddy_count = 0
	beam_present = false
	effective_strength = 0
