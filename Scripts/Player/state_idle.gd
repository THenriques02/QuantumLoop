extends PlayerState
class_name StateIdle

@onready var run: PlayerState = $"../Run"

func enter() -> void:
	player.update_animation("idle")

func exit() -> void:
	pass

func process(delta: float) -> PlayerState:
	if player.move_dir != Vector2.ZERO:
		return run

	player.velocity = Vector2.ZERO

	if player.set_direction():
		player.update_animation("idle")

	return null

func physics(delta: float) -> PlayerState:
	return null

func handle_input(event: InputEvent) -> PlayerState:
	return null
