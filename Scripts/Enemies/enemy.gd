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
	if self.name == "Boss_Knight":
		add_to_group("boss")

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
		return "down"

	var index = get_closest_direction(vector)

	match index:
		0:  # up
			sprite.scale.x = 1
			return "up"
		1:  # diag up right
			sprite.scale.x = 1
			return "diag_up"
		2:  # right
			sprite.scale.x = 1
			return "diag_down"
		3:  # diag down right
			sprite.scale.x = 1
			return "diag_down"
		4:  # down
			sprite.scale.x = 1
			return "down"
		5:  # diag down left (mirrored)
			sprite.scale.x = -1
			return "diag_down"
		6:  # left (mirrored)
			sprite.scale.x = -1
			return "diag_down"
		7:  # diag up left (mirrored)
			sprite.scale.x = -1
			return "diag_up"

	return "down"

func update_animation(state: String) -> void:
	var anim = state + "_" + anim_direction(move_dir)
	$AnimationPlayer.play(anim)

func has_line_of_sight_to(target: Node2D) -> bool:
	if target == null:
		return false

	var to_target = target.global_position - global_position
	if to_target.length() > detection_radius:
		return false

	var exclude_nodes = [self]
	for child in get_children():
		exclude_nodes.append(child)

	var query = PhysicsRayQueryParameters2D.create(global_position, target.global_position)
	query.exclude = exclude_nodes

	var result = get_world_2d().direct_space_state.intersect_ray(query)

	if result.is_empty():
		return true

	var hit = result["collider"]
	return hit == target or hit.is_in_group("player") or hit.get_parent() == target
