extends EnemyState
class_name EnemyStatePursue

@onready var idle: EnemyState = $"../Idle"

func enter() -> void:
	enemy.update_animation("jump")

func process(delta: float) -> EnemyState:
	var player = get_tree().get_first_node_in_group("player")
	if not (player and is_instance_valid(player) and enemy.has_line_of_sight_to(player)):
		return idle
	return null

func physics(delta: float) -> EnemyState:
	var player = get_tree().get_first_node_in_group("player")
	if not (player and is_instance_valid(player)):
		return idle

	var to_player = player.global_position - enemy.global_position
	if to_player.length() < 4.0:
		enemy.velocity = Vector2.ZERO
		enemy.move_dir = to_player.normalized()
		enemy.update_animation("idle")
		return null

	var direction = to_player.normalized()
	enemy.move_dir = direction
	enemy.velocity = direction * enemy.move_speed
	enemy.move_and_slide()
	enemy.update_animation("run")
	return null
