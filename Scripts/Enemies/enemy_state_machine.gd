extends Node
class_name EnemyStateMachine

var states: Array[EnemyState] = []
var current_state: EnemyState = null
var previous_state: EnemyState = null

func initialize(enemy: Enemy) -> void:
	# Gather all EnemyState children and assign their `enemy` reference
	for child in get_children():
		if child is EnemyState:
			child.enemy = enemy
			states.append(child)

	if states.size() > 0:
		current_state = states[0]
		current_state.enter()
		# Enable both Godot callbacks and also allow manual calls below
		set_process(true)
		set_physics_process(true)

func _process(delta: float) -> void:
	# This is the Godot callback; run the current state's `process()`
	if current_state != null:
		var new_state: EnemyState = current_state.process(delta)
		_change_state(new_state)

func _physics_process(delta: float) -> void:
	# This is the Godot physics callback; run the current state's `physics()`
	if current_state != null:
		var new_state: EnemyState = current_state.physics(delta)
		_change_state(new_state)

# Public wrappers so that other scripts (e.g. Enemy.gd) can call these directly
func process(delta: float) -> void:
	_process(delta)

func physics(delta: float) -> void:
	_physics_process(delta)

func _change_state(new_state: EnemyState) -> void:
	if new_state == null or new_state == current_state:
		return

	current_state.exit()
	previous_state = current_state
	current_state = new_state
	current_state.enter()
