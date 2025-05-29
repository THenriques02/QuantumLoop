class_name PlayerState extends Node

static var player: Player
 
func _ready() -> void:
	pass

func Enter() -> void:
	pass

func Exit() -> void:
	pass

func Process(delta: float) -> PlayerState:
	return null

func Physics(delta: float) -> PlayerState:
	return null

func HandleInput(event: InputEvent) -> PlayerState:
	return null
