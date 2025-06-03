extends CharacterBody2D
class_name Enemy

@onready var sprite: Sprite2D = $Sprite2D
@onready var state_machine: EnemyStateMachine = $StateMachine

@export var move_speed: float = 40.0
@export var detection_radius: float = 200.0
@export var damage: int = 10            # HP to remove per hit
@export var attack_radius: float = 16.0  # distance at which the enemy can attack
@export var attack_cooldown: float = 1.0 # seconds between attacks

var move_dir: Vector2 = Vector2.ZERO

# Internal cooldown tracking
var _can_attack: bool = true
var _attack_timer: float = 0.0

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
	# Ensure this node processes both callbacks so the wrappers in EnemyStateMachine work
	set_process(true)
	set_physics_process(true)
	_can_attack = true
	_attack_timer = 0.0

func _process(delta: float) -> void:
	# Forward to the state machine's public `process(...)` method
	state_machine.process(delta)

	# Attack‐cooldown countdown
	if not _can_attack:
		_attack_timer -= delta
		if _attack_timer <= 0.0:
			_can_attack = true

func _physics_process(delta: float) -> void:
	# Forward to the state machine's public `physics(...)` method
	state_machine.physics(delta)

	# After states set move_dir/velocity, do sliding if needed. 
	# (Our states call move_and_slide() themselves, so this is optional.)
	# move_and_slide()

	# Check if we can damage the player (if still in range)
	var current_player = get_tree().get_first_node_in_group("player")
	if current_player and is_instance_valid(current_player) and _can_attack:
		var dist = global_position.distance_to(current_player.global_position)
		if dist <= attack_radius:
			current_player.take_damage(damage)
			_can_attack = false
			_attack_timer = attack_cooldown

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
	# Flip sprite if facing left
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
	if not is_instance_valid(target):
		return false

	var to_target = target.global_position - global_position
	if to_target.length() > detection_radius:
		return false

	var query = PhysicsRayQueryParameters2D.create(global_position, target.global_position)
	query.exclude = [self]
	query.collision_mask = 1 | 2  # walls (1) and player (2)

	var result = get_world_2d().direct_space_state.intersect_ray(query)
	if result.is_empty():
		return true

	var hit = result["collider"]
	return hit == target or hit.get_parent() == target
