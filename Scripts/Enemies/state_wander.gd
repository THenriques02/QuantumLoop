extends EnemyState
class_name EnemyStateWander

@onready var idle: EnemyState = $"../Idle"
@onready var pursue: EnemyState = $"../Pursue"

var wander_timer := 0.0
var wander_duration := 1.5

func enter() -> void:
	wander_timer = 0.0
	enemy.move_dir = enemy.cardinal_directions[randi() % enemy.cardinal_directions.size()]
	enemy.update_animation("jump")

func process(delta: float) -> EnemyState:
	if enemy.has_line_of_sight_to(enemy.player):
		return pursue

	wander_timer += delta
	if wander_timer >= wander_duration:
		return idle
	return null

func physics(delta: float) -> EnemyState:
	enemy.velocity = enemy.move_dir * enemy.move_speed
	enemy.move_and_slide()
	return null
