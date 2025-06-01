extends Node
class_name EnemyState

# Reference to the owning enemy
var enemy: Enemy

# Called when the state is entered
func enter() -> void:
	pass

# Called when the state is exited
func exit() -> void:
	pass

# Per-frame processing logic (non-physics)
func process(delta: float) -> EnemyState:
	return null

# Physics-related logic (called from _physics_process)
func physics(delta: float) -> EnemyState:
	return null
