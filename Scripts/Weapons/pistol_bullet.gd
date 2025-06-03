extends Node2D

@export var speed: float = 500.0
var direction: Vector2 = Vector2.ZERO

@onready var lifetime_timer: Timer = $LifetimeTimer

func _ready() -> void:
	lifetime_timer.timeout.connect(queue_free)
	lifetime_timer.start(3.0)

func _process(delta: float) -> void:
	position += direction * speed * delta
