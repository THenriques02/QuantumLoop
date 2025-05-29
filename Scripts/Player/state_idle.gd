class_name StateIdle extends PlayerState

@onready var run: PlayerState = $"../Run"

func Enter() -> void:
	player.UpdateAnimation("idle")

func Exit() -> void:
	pass

func Process(delta: float) -> PlayerState:
	if player.move_dir != Vector2.ZERO:
		return run
	
	player.velocity = Vector2.ZERO
	
	if player.SetDirection():
		player.UpdateAnimation("idle")
	
	return null

func Physics(delta: float) -> PlayerState:
	return null

func HandleInput(event: InputEvent) -> PlayerState:
	return null
