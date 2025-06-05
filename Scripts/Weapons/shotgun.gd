class_name Shotgun
extends Node2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var muzzle: Marker2D = $Shotgun/Marker2D
@onready var shoot_timer: Timer = $ShootSpeedTimer
@onready var ammo = 0
@onready var picked = false
@onready var selected = false
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var grab_bullets: AudioStreamPlayer2D = $GrabBullets

@export var radius: float = 1.0
@export var shoot_speed: float = 1.0  # Slower than revolver
@export var spread_angle_degrees: float = 15.0  # Total spread arc

const SHELL = preload("res://Scenes/Weapons/shotgun_shell.tscn")
const DEAD_ZONE: float = 0.2

signal shotgun_ammo_changed(new_value: int)

var player: Player
var can_shoot: bool = true
var move_dir: Vector2 = Vector2.ZERO
var controller_dir: Vector2 = Vector2.ZERO
var player_pos: Vector2 = Vector2.ZERO

func _ready() -> void:
	player = get_parent()
	shoot_timer.wait_time = 1.0 / shoot_speed
	shoot_timer.timeout.connect(_on_shoot_speed_timer_timeout)

func _process(delta: float) -> void:
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
	z_index = player.z_index - 1 if move_dir.y < 0 else player.z_index + 1

	if Input.is_action_just_pressed("shoot"):
		shoot()

func shoot() -> void:
	if not can_shoot or ammo < 1 or !picked or !selected:
		return
		
	audio_stream_player_2d.play()
		
	ammo -= 1
	emit_signal("shotgun_ammo_changed", ammo)		

	can_shoot = false
	shoot_timer.start()

	var shell_container = get_tree().root.find_child("BulletContainer", true, false)
	if not shell_container:
		shell_container = get_tree().root

	var base_direction = (get_global_mouse_position() - muzzle.global_position).normalized()
	var base_angle = base_direction.angle()

	for i in range(5):
		var offset = lerp(-spread_angle_degrees / 2, spread_angle_degrees / 2, i / 4.0)
		var shell = SHELL.instantiate()

		var angle_offset_rad = deg_to_rad(offset)
		var direction = Vector2.RIGHT.rotated(base_angle + angle_offset_rad)

		shell.global_position = muzzle.global_position
		shell.rotation = direction.angle()
		shell.direction = direction

		shell_container.add_child(shell)

func _on_shoot_speed_timer_timeout() -> void:
	can_shoot = true

func picked_ammo_shotgun():
	ammo += 6
	emit_signal("shotgun_ammo_changed", ammo)	
	
func picked_shotgun():
	grab_bullets.play()
	picked = true	
	
func selected_revolver():
	selected =false
	
func selected_rifle():
	selected = false		

func selected_shotgun():
	selected = true	
	
func selected_sniper():
	selected = false	
