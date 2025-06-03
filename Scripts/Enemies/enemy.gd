extends CharacterBody2D
class_name Enemy

@onready var sprite: Sprite2D = $Sprite2D
@onready var state_machine: EnemyStateMachine = $StateMachine
@onready var player: Player = get_tree().get_first_node_in_group("player")

@export var move_speed: float = 40.0
@export var detection_radius: float = 200.0

var move_dir: Vector2 = Vector2.ZERO

var cardinal_directions: Array = [
	Vector2.UP,
	Vector2(1, -1).normalized(),
	Vector2.RIGHT,
	Vector2(1, 1).normalized(),
	Vector2.DOWN,
	Vector2(-1, 1).normalized(),
	Vector2.LEFT,
	Vector2(-1, -1).normalized()
]

func _ready() -> void:
	state_machine.initialize(self)

func get_closest_direction(vector: Vector2) -> int:
	vector = vector.normalized()
	var best_index := 0
	var best_dot := -1.0
	for i in range(cardinal_directions.size()):
		var dot := vector.dot(cardinal_directions[i])
		if dot > best_dot:
			best_dot = dot
			best_index = i
	return best_index

func anim_direction(vector: Vector2) -> String:
	if vector == Vector2.ZERO:
		return "down"  # Default animation direction when idle

	var index = get_closest_direction(vector)

	# Flip sprite horizontally if facing left directions
	if index in [5, 6, 7]:
		sprite.scale.x = -1
	else:
		sprite.scale.x = 1

	var anim_dirs = [
		"up",        # 0: up
		"diag_up",   # 1: diag up (right)
		"diag_down", # 2: right
		"diag_down", # 3: diag down (right)
		"down",      # 4: down
		"diag_down", # 5: diag down (left)
		"diag_up",   # 6: left
		"diag_up"    # 7: diag up (left)
	]

	return anim_dirs[index]

func update_animation(state: String) -> void:
	var anim = state + "_" + anim_direction(move_dir)
	$AnimationPlayer.play(anim)

func has_line_of_sight_to(target: Node2D) -> bool:
	if target == null:
		return false

	var to_target = target.global_position - global_position
	if to_target.length() > detection_radius:
		return false

	# Exclude self and all children to avoid self-intersection
	var exclude_nodes = [self]
	for child in get_children():
		exclude_nodes.append(child)

	# Create query without overriding collision_mask to respect inspector layers
	var query = PhysicsRayQueryParameters2D.create(global_position, target.global_position)
	query.exclude = exclude_nodes
	# No query.collision_mask set here; uses physics layers from nodes themselves

	var result = get_world_2d().direct_space_state.intersect_ray(query)

	if result.is_empty():
		return true  # Nothing blocking line of sight

	var hit = result["collider"]
	# Allow for hitting the player or their child nodes
	return hit == target or hit.is_in_group("player") or hit.get_parent() == target
