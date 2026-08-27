extends BlockState
class_name BuddyBlockState

var buddy_count: int

func reset() -> void:
	super.reset()
	buddy_count = 0
