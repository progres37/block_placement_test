extends Object
class_name BlockState

var supported_weight: float
var marked_to_fall: bool
var marked_to_be_crushed: bool

func reset() -> void:
	supported_weight = 0
	marked_to_fall = false
	marked_to_be_crushed = false

func _init() -> void:
	reset()
