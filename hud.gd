extends Control

@onready var selected_block_name_label: Label = $SelectedBlockNameLabel

@export var player: Player

func _on_selected_block_changed() -> void:
	if not player.block_inventory.is_empty():
		selected_block_name_label.text = str(player.selected_block_idx + 1) + ". " + player.block_inventory[player.selected_block_idx].name

func _ready() -> void:
	player.selected_block_changed.connect(_on_selected_block_changed)
	_on_selected_block_changed()
