extends Node
class_name Player

signal selected_block_changed

@export var controlled_character: PlayerCharacter

const COBBLESTONE_BLOCK_PROPERTIES = preload("uid://dbfwy5c82boqu")
const MAGIC_BLOCK_PROPERTIES = preload("uid://x1x1en3qk01u")
const WOOD_BEAM_BLOCK_PROPERTIES = preload("uid://dj3jvf4f0wdwx")



var block_inventory: Array[BlockProperties] = [
	COBBLESTONE_BLOCK_PROPERTIES,
	WOOD_BEAM_BLOCK_PROPERTIES,
	MAGIC_BLOCK_PROPERTIES
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
		if not block_inventory.is_empty():
			controlled_character.interact_secondary(block_inventory[selected_block_idx])
	elif event.is_action_pressed("next_block"):
		if selected_block_idx < block_inventory.size() - 1:
			selected_block_idx += 1
	elif event.is_action_pressed("previous_block"):
		if selected_block_idx > 0:
			selected_block_idx -= 1

func _process(_delta: float) -> void:
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
	
