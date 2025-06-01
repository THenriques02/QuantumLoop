extends Node
class_name EnemyStateMachine

var states: Array[EnemyState] = []
var current_state: EnemyState = null
var previous_state: EnemyState = null

func initialize(enemy: Enemy) -> void:
	for child in get_children():
		if child is EnemyState:
			child.enemy = enemy
			states.append(child)

	if states.size() > 0:
		current_state = states[0]
		current_state.enter()
		process_mode = Node.PROCESS_MODE_INHERIT

func _physics_process(delta: float) -> void:
	if current_state != null:
		var new_state: EnemyState = current_state.physics(delta)
		_change_state(new_state)

func _process(delta: float) -> void:
	if current_state != null:
		var new_state: EnemyState = current_state.process(delta)
		_change_state(new_state)

func _change_state(new_state: EnemyState) -> void:
	if new_state == null or new_state == current_state:
		return

	current_state.exit()
	previous_state = current_state
	current_state = new_state
	current_state.enter()
