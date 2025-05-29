class_name StateRun extends PlayerState

@onready var idle: PlayerState = $"../Idle"

@export var move_speed: float = 100.0

func Enter() -> void:
	player.UpdateAnimation("idle")

func Exit() -> void:
	pass

func Process(delta: float) -> PlayerState:
	if player.move_dir == Vector2.ZERO:
		return idle
	
	player.velocity = player.move_dir * move_speed
	
	if player.SetDirection():
		player.UpdateAnimation("idle")
		
	return null

func Physics(delta: float) -> PlayerState:
	return null

func HandleInput(event: InputEvent) -> PlayerState:
	return null
