class_name Revolver
extends Node2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var muzzle: Marker2D = $Revolver/Marker2D
@onready var shoot_timer: Timer = $ShootSpeedTimer
@onready var selected = true
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

@export var radius: float = 1.0
@export var shoot_speed: float = 4.0

const BULLET = preload("res://Scenes/Weapons/small_bullet.tscn")
const DEAD_ZONE: float = 0.2

var player: Player
var can_shoot: bool = true
var move_dir: Vector2 = Vector2.ZERO
var controller_dir: Vector2 = Vector2.ZERO
var player_pos: Vector2 = Vector2.ZERO

func _ready() -> void:
	player = get_parent()
	shoot_timer.wait_time = 1.0 / shoot_speed
	shoot_timer.timeout.connect(_on_shoot_speed_timer_timeout)

func _process(_delta: float) -> void:
	if player:
		player_pos = player.global_position - Vector2(6, -7.5)

	var mouse_dir = get_global_mouse_position()
	controller_dir = Vector2(
		Input.get_action_strength("look_right") - Input.get_action_strength("look_left"),
		Input.get_action_strength("look_down") - Input.get_action_strength("look_up")
	)

	move_dir = controller_dir.normalized() if controller_dir.length() > DEAD_ZONE else (mouse_dir - player_pos).normalized()

	global_position = player_pos + move_dir * radius
	look_at(mouse_dir)

	rotation_degrees = wrap(rotation_degrees, 0, 360)
	scale.y = -1 if rotation_degrees > 90 and rotation_degrees < 270 else 1

	# Adjust revolver Z index based on player's look direction
	var anim_dir := player.anim_direction(player.look_dir)
	if anim_dir == "up" or anim_dir == "diag_up":
		z_index = player.z_index - 1  # Behind player
	else:
		z_index = player.z_index + 1  # In front of player

	if Input.is_action_just_pressed("shoot"):
		shoot()

func shoot() -> void:
	if not can_shoot or !selected:
		return

	audio_stream_player_2d.play()

	can_shoot = false
	shoot_timer.start()

	var bullet = BULLET.instantiate()
	var bullet_container = get_tree().get_root().find_child("BulletContainer", true, false)

	if bullet_container:
		bullet_container.add_child(bullet)
	else:
		get_tree().root.add_child(bullet)

	var direction = (get_global_mouse_position() - muzzle.global_position).normalized()
	bullet.global_position = muzzle.global_position
	bullet.rotation = direction.angle()
	bullet.direction = direction

func _on_shoot_speed_timer_timeout() -> void:
	can_shoot = true
	
func selected_revolver():
	selected = true
	
func selected_rifle():
	selected = false		

func selected_shotgun():
	selected = false	
	
func selected_sniper():
	selected = false		
