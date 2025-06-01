extends EnemyState
class_name EnemyStateIdle

@onready var wander: EnemyState = $"../Wander"
@onready var pursue: EnemyState = $"../Pursue"

func enter() -> void:
	enemy.move_dir = Vector2.ZERO
	enemy.velocity = Vector2.ZERO
	enemy.update_animation("idle")

func process(delta: float) -> EnemyState:
	# Check for player detection first
	if enemy.has_line_of_sight_to(enemy.player):
		return pursue
	
	# Transition to wandering otherwise
	return wander

func physics(delta: float) -> EnemyState:
	return null
	
