extends Node
class_name Player

signal selected_block_changed

const NORMAL_BLOCK_PROPERTIES = preload("res://block_properties/normal_block_properties.tres")
const SUPPORT_BLOCK_PROPERTIES = preload("res://block_properties/support_block_properties.tres")

@export var controlled_character: PlayerCharacter

var block_inventory: Array[BlockProperties] = [
	NORMAL_BLOCK_PROPERTIES,
	SUPPORT_BLOCK_PROPERTIES
]
var selected_block_idx: int = 0:
	set(value):
		selected_block_idx = value
		selected_block_changed.emit()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode != Input.MOUSE_MODE_VISIBLE:
		controlled_character.change_look_direction(-event.relative)
	elif event.is_action_pressed("interact_primary"):
		controlled_character.interact_primary()
	elif event.is_action_pressed("interact_secondary"):
		controlled_character.interact_secondary(block_inventory[selected_block_idx])
	elif event.is_action_pressed("next_block"):
		if selected_block_idx < block_inventory.size() - 1:
			selected_block_idx += 1
	elif event.is_action_pressed("previous_block"):
		if selected_block_idx > 0:
			selected_block_idx -= 1

func _process(delta: float) -> void:
	var move_direction_versor: Vector3 = Vector3(0, 0, 0)
	if Input.is_action_pressed("move_forward"):
		move_direction_versor += Vector3(1, 0, 0)
	if Input.is_action_pressed("move_backward"):
		move_direction_versor += Vector3(-1, 0, 0)
	if Input.is_action_pressed("move_right"):
		move_direction_versor += Vector3(0, 0, 1)
	if Input.is_action_pressed("move_left"):
		move_direction_versor += Vector3(0, 0, -1)
	if Input.is_action_pressed("move_up"):
		move_direction_versor += Vector3(0, 1, 0)
	if Input.is_action_pressed("move_down"):
		move_direction_versor += Vector3(0, -1, 0)
	move_direction_versor = move_direction_versor.normalized()
	controlled_character.move_direction_versor = move_direction_versor
	
