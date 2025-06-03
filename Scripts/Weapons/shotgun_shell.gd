extends Node2D
class_name ShotgunShell

@export var speed: float = 400.0
@export var lifetime: float = 0.5

var direction: Vector2 = Vector2.ZERO
var life_timer: float = 0.0

func _ready() -> void:
	life_timer = 0.0
	set_process(true)

func _process(delta: float) -> void:
	position += direction * speed * delta
	life_timer += delta

	if life_timer >= lifetime:
		queue_free()
