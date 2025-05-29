extends CharacterBody2D
class_name Player

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var state_machine: PlayerStateMachine = $StateMachine

var move_dir: Vector2 = Vector2.ZERO
var look_dir: Vector2 = Vector2.ZERO
var cardinal_direction: Vector2 = Vector2.DOWN

var directions: Array = [
	Vector2.UP,
	Vector2(1, -1).normalized(),
	Vector2.RIGHT,
	Vector2(1, 1).normalized(),
	Vector2.DOWN,
	Vector2(-1, 1).normalized(),
	Vector2.LEFT,
	Vector2(-1, -1).normalized()
]

func _ready() -> void:
	state_machine.initialize(self)

func _process(delta: float) -> void:
	move_dir.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	move_dir.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	
	if move_dir.length() > 0:
		move_dir = move_dir.normalized()

	look_dir = (get_global_mouse_position() - global_position).normalized()

func _physics_process(delta: float) -> void:
	move_and_slide()

func get_closest_direction(vector: Vector2) -> int:
	var closest_index: int = 0
	var closest_dot: float = -1.0
	
	for i in range(directions.size()):
		var dot: float = vector.dot(directions[i])
		if dot > closest_dot:
			closest_dot = dot
			closest_index = i
	
	return closest_index

func set_direction() -> bool:
	var old_dir: Vector2 = cardinal_direction
	cardinal_direction = directions[get_closest_direction(look_dir)]
	return old_dir != cardinal_direction

func update_animation(state: String) -> void:
	var animation_name: String = state + "_" + anim_direction(look_dir)
	animation_player.play(animation_name)

func anim_direction(vector: Vector2) -> String:
	var closest_index: int = get_closest_direction(vector)

	if closest_index < 5:
		sprite.scale.x = 1
	else:
		sprite.scale.x = -1

	match closest_index:
		0: return "up"
		1: return "diag_up"
		2: return "right"
		3: return "diag_down"
		4: return "down"
		5: return "diag_down"
		6: return "right"
		7: return "diag_up"

	return "down"
