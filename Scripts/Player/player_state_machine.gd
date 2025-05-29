class_name PlayerStateMachine extends Node

var states: Array[PlayerState]
var prev_state: PlayerState
var current_state: PlayerState

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED

func _process(delta: float) -> void:
	ChangeState(current_state.Process(delta))

func _physics_process(delta: float) -> void:
	ChangeState(current_state.Physics(delta))

func _unhandled_input(event: InputEvent) -> void:
	ChangeState(current_state.HandleInput(event))

func Initialize(player: Player) -> void:
	states = []
	
	for c in get_children():
		if c is PlayerState:
			states.append(c)
	
	if states.size() > 0:
		states[0].player = player
		ChangeState(states[0])
		process_mode = Node.PROCESS_MODE_INHERIT

func ChangeState(new_state: PlayerState) -> void:
	if new_state == null || new_state == current_state:
		return
		
	if current_state:
		current_state.Exit()
	
	prev_state = current_state
	current_state = new_state
	
	current_state.Enter()
