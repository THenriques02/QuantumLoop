extends PlayerState
class_name StateRun

@onready var idle: PlayerState = $"../Idle"
@export var move_speed: float = 100.0

func enter() -> void:
	player.update_animation("idle")

func exit() -> void:
	pass

func process(_delta: float) -> PlayerState:
	if player.move_dir == Vector2.ZERO:
		return idle

	player.velocity = player.move_dir * move_speed

	if player.set_direction():
		player.update_animation("idle")

	return null

func physics(_delta: float) -> PlayerState:
	return null

func handle_input(_event: InputEvent) -> PlayerState:
	return null
