extends EnemyState
class_name EnemyStateIdle

@onready var wander: EnemyState = $"../Wander"
@onready var pursue: EnemyState = $"../Pursue"

func enter() -> void:
	enemy.move_dir = Vector2.ZERO
	enemy.velocity = Vector2.ZERO
	enemy.update_animation("idle")

func process(delta: float) -> EnemyState:
	var player = get_tree().get_first_node_in_group("player")
	if player and is_instance_valid(player) and enemy.has_line_of_sight_to(player):
		return pursue
	return wander

func physics(delta: float) -> EnemyState:
	# Idle does not move
	return null
