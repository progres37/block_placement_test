extends Node

func _init() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_released("quit"):
		get_tree().quit()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("free_mouse"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	elif event.is_action_released("free_mouse"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
