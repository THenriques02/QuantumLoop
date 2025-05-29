extends Node
class_name PlayerStateMachine

var states: Array[PlayerState] = []
var current_state: PlayerState = null
var previous_state: PlayerState = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED

func initialize(p: Player) -> void:
	for child in get_children():
		if child is PlayerState:
			var state: PlayerState = child
			state.player = p
			states.append(state)

	if states.size() > 0:
		current_state = states[0]
		current_state.enter()
		process_mode = Node.PROCESS_MODE_INHERIT

func _physics_process(delta: float) -> void:
	if current_state:
		var new_state: PlayerState = current_state.physics(delta)
		_change_state(new_state)

func _process(delta: float) -> void:
	if current_state:
		var new_state: PlayerState = current_state.process(delta)
		_change_state(new_state)

func _unhandled_input(event: InputEvent) -> void:
	if current_state:
		var new_state: PlayerState = current_state.handle_input(event)
		_change_state(new_state)

func _change_state(new_state: PlayerState) -> void:
	if new_state == null or new_state == current_state:
		return

	current_state.exit()
	previous_state = current_state
	current_state = new_state
	current_state.enter()
