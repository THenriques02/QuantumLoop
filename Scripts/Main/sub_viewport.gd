extends SubViewport

@onready var camera = $Camera2D

var player_ref: Player

func set_player(player):
	player_ref = player
	
func _physics_process(_delta):
	if player_ref:
		camera.position = player_ref.position

func set_world(world):
	world_2d = world
