extends Node3D
class_name PlayerCharacter


@onready var head: Node3D = $Head
@onready var ray_cast_3d: RayCast3D = $Head/RayCast3D

@export var movement_speed: float = 2
@export var look_speed: float = 0.5
@export var reach: float = 3.0

var current_ray_cast_collider = null
var move_direction_versor: Vector3 = Vector3(0, 0, 0)

func change_look_direction(delta: Vector2) -> void:
	delta = delta * look_speed
	rotation_degrees.y += delta.x
	if abs(head.rotation_degrees.z + delta.y) < 90:
		head.rotation_degrees.z += delta.y

func interact_primary() -> void:
	if current_ray_cast_collider is Block:
		current_ray_cast_collider.interact_primary()

func interact_secondary(selected_block: BlockProperties) -> void:
	if current_ray_cast_collider is Block:
		var collision_direction = ray_cast_3d.get_collision_normal()
		current_ray_cast_collider.interact_secondary(collision_direction, selected_block)

func _ready() -> void:
	ray_cast_3d.target_position = reach * Vector3(1, 0, 0)

func _physics_process(delta: float) -> void:
	var velocity: Vector3 = move_direction_versor * basis.orthonormalized().inverse() * movement_speed
	position += velocity * delta

func _process(_delta: float) -> void:
	var previous_ray_cast_collider = current_ray_cast_collider
	current_ray_cast_collider = ray_cast_3d.get_collider()
	if previous_ray_cast_collider != current_ray_cast_collider:
		if current_ray_cast_collider is Block:
			current_ray_cast_collider.make_selected()
		if previous_ray_cast_collider is Block:
			previous_ray_cast_collider.make_unselected()
