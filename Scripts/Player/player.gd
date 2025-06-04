extends CharacterBody2D
class_name Player

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var state_machine: PlayerStateMachine = $StateMachine

var move_dir: Vector2 = Vector2.ZERO
var look_dir: Vector2 = Vector2.ZERO
var cardinal_direction: Vector2 = Vector2.DOWN
var health_potions = 0
var ammo_shotgun = 0
var ammo_sniper = 0
var ammo_rifle = 0

var directions: Array = [
	Vector2.UP,
	Vector2(1, -1).normalized(),
	Vector2(1, 1).normalized(),
	Vector2.DOWN,
	Vector2(-1, 1).normalized(),
	Vector2(-1, -1).normalized()
]

func _ready() -> void:
	state_machine.initialize(self)
	add_to_group("player")

func _process(_delta: float) -> void:
	move_dir.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	move_dir.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	
	if move_dir.length() > 0:
		move_dir = move_dir.normalized()

	look_dir = (get_global_mouse_position() - global_position).normalized()

func _physics_process(_delta: float) -> void:
	move_and_slide()

func get_closest_direction(vector: Vector2) -> int:
	vector = vector.normalized()
	var best_index := 0
	var best_dot := -1.0
	for i in range(directions.size()):
		var dot := vector.dot(directions[i])
		if dot > best_dot:
			best_dot = dot
			best_index = i
	return best_index

func set_direction() -> bool:
	var old_dir: Vector2 = cardinal_direction
	cardinal_direction = directions[get_closest_direction(look_dir)]
	return old_dir != cardinal_direction

func anim_direction(vector: Vector2) -> String:
	if vector == Vector2.ZERO:
		return "down"

	var index = get_closest_direction(vector)

	match index:
		0:  # up
			sprite.scale.x = 1
			return "up"
		1:  # diag up right
			sprite.scale.x = 1
			return "diag_up"
		2:  # diag down right
			sprite.scale.x = 1
			return "diag_down"
		3:  # down
			sprite.scale.x = 1
			return "down"
		4:  # diag down left (mirrored)
			sprite.scale.x = -1
			return "diag_down"
		5:  # diag up left (mirrored)
			sprite.scale.x = -1
			return "diag_up"

	return "down"

func update_animation(state: String) -> void:
	var animation_name: String = state + "_" + anim_direction(look_dir)
	animation_player.play(animation_name)

func picked_health():
	health_potions += 1

func picked_ammo():
	ammo_shotgun += 32
	ammo_sniper += 16
	ammo_rifle += 64
