extends Node2D

var Room = preload("res://Scenes/Dungeon/Room.tscn")
var font = preload("res://Assets/Dungeon/Roboto-VariableFont_wdth,wght.ttf")
var Player = preload("res://Scenes/Player/player.tscn")
var Ui = preload("res://Scenes/UI/control.tscn")

#Corpse
var Corpse_Loot = preload("res://Scenes/Loot/corpse_loot.tscn")

#Enemies
var Slime = preload("res://Scenes/Enemies/slime.tscn")
var Knight = preload("res://Scenes/Enemies/knight.tscn")
var Boss_Knight = preload("res://Scenes/Enemies/boss_knight.tscn")

#Objects
var Chest = preload("res://Scenes/Dungeon/chest.tscn")
var Weapon_Box = preload("res://Scenes/Dungeon/weapon_box.tscn")

#loot
var Health = preload("res://Scenes/Loot/health_potion.tscn")
var Ammo = preload("res://Scenes/Loot/ammo.tscn")
var Loot_Rifle = preload("res://Scenes/Loot/rifle.tscn")
var Loot_Shotgun = preload("res://Scenes/Loot/shotgun.tscn")
var Loot_Sniper = preload("res://Scenes/Loot/sniper.tscn")

@onready var walls_floor_map = $Walls_Floor
@onready var death: AudioStreamPlayer2D = $Death
@onready var next_level: AudioStreamPlayer2D = $NextLevel

var ui_instance

var tile_size = 16 # size of tile in the TileMap
var margin_tiles = 500
var num_rooms = 40 # numer of rooms to generate
var min_size = 20   # minimum room size ( in tiles)
var max_size = 40  # maximum room size (in tiles )
var hspread = 20   # horizontal spread ( in pixels )
var cull = 0.25     # chance to cull the room
var seed = randi()

var path           # AStar pathfinding object
var start_room = null
var end_room = null
var play_mode = false
var player = null
var map_completed = false

var difficulty_modifier = 0
var era = 0
var negative_eras = 0
var eras_rooms = {}
var eras_paths = {}
var path_switch = []
var switch_index = 0
var eras_corpses = {}

var base_min_enemies = 5
var base_max_enemies = 10
var base_slime_percentage = 0.8

var base_loot_box_percentage = 0.6
var base_loot_percentage = 0.6
var base_non_loot_weapons_percentage = 0.7

var high_score = 0
signal high_score_changed(new_value: int)
const savefile = "user://savefile.save"
var save_name = "Miguel"

func _ready():
	randomize()
	await make_rooms()
	await make_map()
	$Background.visible = false
	$Maintext.visible = false
	$Subtext.visible = false
		

"""
func _draw():
	if start_room:
		draw_string(font, start_room.position, "start", 0, -1, 16, Color(1, 1, 1))
	if end_room:
		draw_string(font, end_room.position, "end", 0, -1, 16, Color(1, 1, 1))
	if play_mode:
		return		
	for room in $Rooms.get_children():
		draw_rect(Rect2(room.position - room.size + room.size / 2, room.size), Color(0,1,0), false)
	if path:
		for p in path.get_point_ids():
			for c in path.get_point_connections(p):
				var pp = path.get_point_position(p)
				var cp = path.get_point_position(c)
				draw_line(pp,cp, Color(1,1,0), 5, true)	
		
func _process(delta):
	queue_redraw()
"""		
func _input(event):
	if event.is_action_pressed("ui_page_down") and player:
		map_completed = false
		_show_death_ui()
		player_died()
		
	if event.is_action_pressed("ui_page_up") and player:
		map_completed = false
		_show_survive_ui()
		player_passed()
			
	if event.is_action_pressed('ui_cancel'):
		save_score()
		get_tree().quit()
				
	if event.is_action_pressed('ui_accept'):
		if play_mode or !map_completed:
			return
			
		spawn_enemies()
		spawn_objects()
		spawn_corpses()
				
		player = Player.instantiate()
		add_child(player)
		player.position = start_room.position
		
		await get_tree().create_timer(0.1).timeout
		
		var cam = player.get_node("Camera2D")
		if cam:
			cam.make_current()
		
		var map_cam = self.get_node("Camera2D")	
		ui_instance = Ui.instantiate()
		ui_instance.get_node("UI/SubViewportContainer/SubViewport").set_player(player)
		ui_instance.get_node("UI/SubViewportContainer/SubViewport").set_world(get_tree().root.world_2d)
		ui_instance.get_node("UI/Status/HealthBar").set_health_component(player.get_node("HealthComponent"))
		ui_instance.get_node("UI/Heals/Label").connect_player(player)
		ui_instance.get_node("UI/RifleAmmo/Label").connect_rifle(player.get_node("Rifle"))
		ui_instance.get_node("UI/ShotgunAmmo/Label").connect_shotgun(player.get_node("Shotgun"))
		ui_instance.get_node("UI/SniperAmmo/Label").connect_sniper(player.get_node("Sniper"))
		ui_instance.get_node("UI/HighScore/Value").connect_main(self)
		$minimap.add_child(ui_instance)

		play_mode = true	

func i_died():
	map_completed = false
	_show_death_ui()
	player_died()

func boss_died():
	map_completed = false
	_show_survive_ui()
	player_passed()

func _show_death_ui():
	$Maintext.text = "You Died"
	$Subtext.text = "Forward to the Past"
	$Background.visible = true
	$Maintext.visible = true
	$Subtext.visible = true
	
func _show_survive_ui():
	$Maintext.text = "You Survived"
	$Subtext.text = "Back to the Future"
	$Background.visible = true
	$Maintext.visible = true
	$Subtext.visible = true	

func spawn_enemies():
	for room in$Rooms.get_children():
		if room == end_room:
			var boss = Boss_Knight.instantiate()
			boss.position = room.position
			boss.get_node("HealthComponent").max_health *= 1 + (difficulty_modifier*0.25)
			$Enemies.add_child(boss)
			
		elif room != start_room:	
			var enemy_count = randi_range(base_min_enemies + int(floor(0.2 * difficulty_modifier)) , base_max_enemies + 1 * difficulty_modifier)
			for i in range(enemy_count):
				var enemy
				if randf() < max(base_slime_percentage - 0.025 * difficulty_modifier, 0.4):
					enemy = Slime.instantiate()
					connect_slime_health_component(enemy.get_node("HealthComponent"))
				else:
					enemy = Knight.instantiate()
					connect_knight_health_component(enemy.get_node("HealthComponent"))	
				
				var half_w = room.size.x / 2 - ( 2 * tile_size)
				var half_h = room.size.y / 2 - ( 2 * tile_size)
				
				var rx = room.position.x + randf_range(-half_w, half_w)
				var ry = room.position.y + randf_range(-half_h, half_h)
				enemy.position = Vector2(rx, ry)
				$Enemies.add_child(enemy)

func spawn_corpses():
	if eras_corpses.has(era):
			for corpses in eras_corpses[era]:
				var corpse_loot = Corpse_Loot.instantiate()
				corpse_loot.position = corpses[0]
				corpse_loot.set_health_potions(corpses[1])
				corpse_loot.set_rifle(corpses[2])
				corpse_loot.set_rifle_ammo(corpses[3])
				corpse_loot.set_shotgun(corpses[4])
				corpse_loot.set_shotgun_ammo(corpses[5])
				corpse_loot.set_sniper(corpses[6])
				corpse_loot.set_sniper_ammo(corpses[7])
				$Corpses.add_child(corpse_loot)

func spawn_objects():
	for room in $Rooms.get_children():
		if randf() < max(base_loot_box_percentage - 0.025 * difficulty_modifier, 0.25):
			var num_objects = randi_range(1, 5)
			for i in range(num_objects):

				var half_w = room.size.x / 2 - ( 2 * tile_size)
				var half_h = room.size.y / 2 - ( 2 * tile_size)
				var rx = room.position.x + randf_range(-half_w, half_w)
				var ry = room.position.y + randf_range(-half_h, half_h)
				
				var object
				var loot
				if randf() < min(base_non_loot_weapons_percentage + 0.01 * difficulty_modifier, 0.95):
					object = Chest.instantiate()
					if randf() < max(base_loot_percentage - 0.025 * difficulty_modifier, 0.25):
						if randf() < 0.6:
							loot = Health.instantiate()
						else:
							loot = Ammo.instantiate()
						loot.position = Vector2(rx, ry)
				
				else:
					object = Weapon_Box.instantiate()
					var perc = randf()
					if perc < 0.5:
						loot = Loot_Rifle.instantiate()
					elif perc < 0.8:
						loot = Loot_Shotgun.instantiate()
					else:
						loot = Loot_Sniper.instantiate()
					loot.position = Vector2(rx, ry)
				
				if loot:
					$Objects.add_child(loot)
				
				object.position = Vector2(rx, ry)
				$Objects.add_child(object)

func make_rooms():
	for i in range(num_rooms):
		var pos = Vector2(randi_range(-hspread, hspread),0)
		var r = Room.instantiate()
		var w = min_size + randi() % (max_size - min_size)
		var h = min_size + randi() % (max_size - min_size)
		r.make_room(pos, Vector2(w,h) * tile_size)
		$Rooms.add_child(r)
	# wait for movement to stop
	await(get_tree().create_timer(1.1).timeout)
	
	var room_positions = []
	# cull rooms
	for room in $Rooms.get_children():
		if randf() < cull:
			room.queue_free()
		else:
			room.freeze = true
			room_positions.append(room.position)
	
	await(get_tree().create_timer(1.1).timeout)
	
	# generate a minimum spanning treee connecting the rooms
	path = find_mst(room_positions)
			
func find_mst(nodes):
	var path = AStar2D.new()
	path.add_point(path.get_available_point_id(), nodes.pop_front())
	
	#repeat until no more nodes remain
	while nodes:
		var min_dist = INF # Minimum distance so far
		var min_p = null   # Position of that node
		var p = null       # current position
		for p1 in path.get_point_ids():
			var p_temp = path.get_point_position(p1)
			for p2 in nodes:
				if p_temp.distance_to(p2) < min_dist:
					min_dist = p_temp.distance_to(p2)
					min_p = p2
					p = p_temp
		
		var n = path.get_available_point_id()
		path.add_point(n, min_p)
		path.connect_points(path.get_closest_point(p), n)
		nodes.erase(min_p)
		
	return path				

func make_map():
	walls_floor_map.clear()
	await(get_tree().create_timer(1.1).timeout) 
	find_start_room()
	find_end_room()
	
	# Fill TileMap with walls, then carve empty rooms
	var full_rect = Rect2()
	for room in $Rooms.get_children():
		var r = Rect2(room.position - room.size / 2 , room.size)
		full_rect = full_rect.merge(r)
	
	var margin_pixels = tile_size * margin_tiles
	full_rect = full_rect.grow(margin_pixels)
	
	var top_left = walls_floor_map.local_to_map(full_rect.position)
	var bottom_right = walls_floor_map.local_to_map(full_rect.end)
	for x in range(top_left.x, bottom_right.x):
		for y in range(top_left.y, bottom_right.y):	
			walls_floor_map.set_cell(Vector2i(x, y), 0, Vector2i(1, 1))
	
	# carve rooms
	var corridors = []
	for room in $Rooms.get_children():
		var s = (room.size / tile_size).floor()  # size in tiles
		var ul = ((room.position - room.size + room.size / 2))/tile_size  # top-left in tile coords
		
		var count_x = 0
		
		for x in range(s.x-1):
			var count_y = 0	
			for y in range(s.y-1):
				walls_floor_map.set_cell(Vector2i(ul.x + x, ul.y + y), 0, Vector2i(1, 6))
				if count_x == 0 and count_y == 0:
					walls_floor_map.set_cell(Vector2i(ul.x + x, ul.y + y), 0, Vector2i(3, 0))	
				elif count_x == s.x-2 and count_y == 0:
					walls_floor_map.set_cell(Vector2i(ul.x + x, ul.y + y), 0, Vector2i(5, 0))
				elif count_x == s.x-2 and count_y ==  s.y-2:
					walls_floor_map.set_cell(Vector2i(ul.x + x, ul.y + y), 0, Vector2i(5, 3))
				elif count_x == 0 and count_y == s.y-2:
					walls_floor_map.set_cell(Vector2i(ul.x + x, ul.y + y), 0, Vector2i(3, 3))		
				elif count_y == 0:
					walls_floor_map.set_cell(Vector2i(ul.x + x, ul.y + y), 0, Vector2i(1, 2))	
				elif count_y == s.y-2:
					walls_floor_map.set_cell(Vector2i(ul.x + x, ul.y + y), 0, Vector2i(4, 3))	
				elif count_x == 0:
					walls_floor_map.set_cell(Vector2i(ul.x + x, ul.y + y), 0, Vector2i(2, 1))
				elif count_x == s.x-2:
					walls_floor_map.set_cell(Vector2i(ul.x + x, ul.y + y), 0, Vector2i(5, 1))	
				count_y += 1
			count_x += 1	

	for room in $Rooms.get_children():
		var p = path.get_closest_point(room.position)
		for conn in path.get_point_connections(p):
			if not conn in corridors:
				var start = walls_floor_map.local_to_map(path.get_point_position(p))
				var end = walls_floor_map.local_to_map(path.get_point_position(conn))
				
				carve_path(start, end)
		corridors.append(p)
	
	for room in $Rooms.get_children():
		room.get_node("CollisionShape2D").disabled = true
	
	$Background.visible = false
	$Maintext.visible = false
	$Subtext.visible = false
	map_completed = true
						 
func carve_path(pos1, pos2):
	# Carve a path between 2 points
	var x_diff = sign(pos2.x - pos1.x)
	var y_diff = sign(pos2.y - pos1.y)
	if x_diff == 0: x_diff = pow(-1.0, randi() % 2)
	if y_diff == 0: y_diff = pow(-1.0, randi() % 2)	
	
	# choose either x/y or y/x
	var x_y = pos1
	var y_x = pos2
	if eras_paths.has(era):
		var values = eras_paths[era]
		if values[1][switch_index]:
			x_y = pos2
			y_x = pos1
		switch_index += 1	
	else:	
		var switch = false
		if (randi() % 2) > 0:
			x_y = pos2
			y_x = pos1
			switch = true
		path_switch.append(switch)	
	
	if x_diff > 0:
		if walls_floor_map.get_cell_atlas_coords(Vector2i(pos1.x,x_y.y)) == Vector2i(1,1):
			walls_floor_map.set_cell(Vector2i(pos1.x - x_diff, x_y.y), 0,  Vector2i(2, 1))
			walls_floor_map.set_cell(Vector2i(pos1.x - x_diff, x_y.y + y_diff), 0,  Vector2i(2, 1))
			
	else:
		if walls_floor_map.get_cell_atlas_coords(Vector2i(pos1.x,x_y.y)) == Vector2i(1,1):
			walls_floor_map.set_cell(Vector2i(pos1.x - x_diff, x_y.y), 0,  Vector2i(0, 1))
			walls_floor_map.set_cell(Vector2i(pos1.x - x_diff, x_y.y + y_diff), 0,  Vector2i(0, 1))
	
	if y_diff > 0:
		if walls_floor_map.get_cell_atlas_coords(Vector2i(y_x.x, pos1.y)) == Vector2i(1,1):
			walls_floor_map.set_cell(Vector2i(y_x.x, pos1.y - y_diff), 0, Vector2i(1, 2))
			walls_floor_map.set_cell(Vector2i(y_x.x + x_diff, pos1.y - y_diff), 0, Vector2i(1, 2))
	else:
		if walls_floor_map.get_cell_atlas_coords(Vector2i(y_x.x, pos1.y)) == Vector2i(1,1):
			walls_floor_map.set_cell(Vector2i(y_x.x, pos1.y - y_diff), 0, Vector2i(1, 0))
			walls_floor_map.set_cell(Vector2i(y_x.x + x_diff, pos1.y - y_diff), 0, Vector2i(1, 0))

		


	for x in range(pos1.x, pos2.x, x_diff):
		if walls_floor_map.get_cell_atlas_coords(Vector2i(x,x_y.y)) == Vector2i(1,6) and walls_floor_map.get_cell_atlas_coords(Vector2i(x,x_y.y + y_diff)) == Vector2i(1,6):
			continue
		var tile_2y_diff =  walls_floor_map.get_cell_atlas_coords(Vector2i(x,x_y.y + 2 * y_diff))
		var tile_neg_y_diff =  walls_floor_map.get_cell_atlas_coords(Vector2i(x,x_y.y - y_diff))
		
		if y_diff > 0:
			# Walls
			if tile_2y_diff == Vector2i(1,1):
				walls_floor_map.set_cell(Vector2i(x, x_y.y + 2 * y_diff), 0,  Vector2i(4, 3))
			elif tile_2y_diff == Vector2i(3,3) or tile_2y_diff == Vector2i(5,3):
				walls_floor_map.set_cell(Vector2i(x, x_y.y + 2 * y_diff), 0,  Vector2i(4, 3))	
			elif tile_2y_diff == Vector2i(2,1):
				walls_floor_map.set_cell(Vector2i(x, x_y.y + 2 * y_diff), 0,  Vector2i(2, 0))
			elif tile_2y_diff == Vector2i(5,1):
				walls_floor_map.set_cell(Vector2i(x, x_y.y + 2 * y_diff), 0,  Vector2i(0, 0))
			
			if 	tile_neg_y_diff == Vector2i(1,1):
				walls_floor_map.set_cell(Vector2i(x, x_y.y - y_diff), 0,  Vector2i(1, 2))
			elif tile_neg_y_diff == Vector2i(3,0) or tile_neg_y_diff == Vector2i(5,0):
				walls_floor_map.set_cell(Vector2i(x, x_y.y - y_diff), 0,  Vector2i(1, 2))	
			elif tile_neg_y_diff == Vector2i(2,1):
				walls_floor_map.set_cell(Vector2i(x, x_y.y - y_diff), 0,  Vector2i(2, 2))
			elif tile_neg_y_diff == Vector2i(5,1):
				walls_floor_map.set_cell(Vector2i(x, x_y.y - y_diff), 0,  Vector2i(0, 2))
				
		else:
			if tile_2y_diff == Vector2i(1,1):
				walls_floor_map.set_cell(Vector2i(x, x_y.y + 2 * y_diff), 0,  Vector2i(1, 2))
			elif tile_2y_diff == Vector2i(3,0) or tile_2y_diff == Vector2i(5,0):
				walls_floor_map.set_cell(Vector2i(x, x_y.y + 2 * y_diff), 0,  Vector2i(1, 2))	
			elif tile_2y_diff == Vector2i(2,1):
				walls_floor_map.set_cell(Vector2i(x, x_y.y + 2 * y_diff), 0,  Vector2i(2, 2))
			elif tile_2y_diff == Vector2i(5,1):
				walls_floor_map.set_cell(Vector2i(x, x_y.y + 2 * y_diff), 0,  Vector2i(0, 2))
				
			if 	tile_neg_y_diff == Vector2i(1,1):
				walls_floor_map.set_cell(Vector2i(x, x_y.y - y_diff), 0,  Vector2i(4, 3))
			elif tile_neg_y_diff == Vector2i(3,3) or tile_neg_y_diff == Vector2i(5,3):
				walls_floor_map.set_cell(Vector2i(x, x_y.y - y_diff), 0,  Vector2i(4, 3))	
			elif tile_neg_y_diff == Vector2i(2,1):
				walls_floor_map.set_cell(Vector2i(x, x_y.y - y_diff), 0,  Vector2i(2, 0))
			elif tile_neg_y_diff == Vector2i(5,1):
				walls_floor_map.set_cell(Vector2i(x, x_y.y - y_diff), 0,  Vector2i(0, 0))								
		
		walls_floor_map.set_cell(Vector2i(x, x_y.y), 0,  Vector2i(1, 6))
		walls_floor_map.set_cell(Vector2i(x, x_y.y + y_diff), 0,  Vector2i(1, 6))
	
	for y in range(pos1.y, pos2.y, y_diff):
		if walls_floor_map.get_cell_atlas_coords(Vector2i(y_x.x,y)) == Vector2i(1,6) and walls_floor_map.get_cell_atlas_coords(Vector2i(y_x.x + x_diff,y)) == Vector2i(1,6):
			continue	
		
		var tile_2x_diff =  walls_floor_map.get_cell_atlas_coords(Vector2i(y_x.x + 2 * x_diff,y))
		var tile_neg_x_diff =  walls_floor_map.get_cell_atlas_coords(Vector2i(y_x.x - x_diff,y))
		
		if x_diff > 0:
			if tile_2x_diff == Vector2i(1,1):
				walls_floor_map.set_cell(Vector2i(y_x.x + 2 * x_diff, y), 0, Vector2i(0, 1))
			elif tile_2x_diff == Vector2i(1,2):
				walls_floor_map.set_cell(Vector2i(y_x.x + 2 * x_diff, y), 0, Vector2i(0, 2))
			elif tile_2x_diff == Vector2i(4,3):
				walls_floor_map.set_cell(Vector2i(y_x.x + 2 * x_diff, y), 0, Vector2i(0, 0))
				
			if tile_neg_x_diff == Vector2i(1,1):
				walls_floor_map.set_cell(Vector2i(y_x.x - x_diff, y), 0, Vector2i(2, 1))
			elif tile_neg_x_diff == Vector2i(1,2):
				walls_floor_map.set_cell(Vector2i(y_x.x - x_diff, y), 0, Vector2i(2, 2))
			elif tile_neg_x_diff == Vector2i(4,3):
				walls_floor_map.set_cell(Vector2i(y_x.x - x_diff, y), 0, Vector2i(2, 0))
		
		else:	
			if tile_2x_diff == Vector2i(1,1):
				walls_floor_map.set_cell(Vector2i(y_x.x + 2 * x_diff, y), 0, Vector2i(2, 1))
			elif tile_2x_diff == Vector2i(1,2):
				walls_floor_map.set_cell(Vector2i(y_x.x + 2 * x_diff, y), 0, Vector2i(2, 2))
			elif tile_2x_diff == Vector2i(4,3):
				walls_floor_map.set_cell(Vector2i(y_x.x + 2 * x_diff, y), 0, Vector2i(2, 0))
				
			if tile_neg_x_diff == Vector2i(1,1):
				walls_floor_map.set_cell(Vector2i(y_x.x - x_diff, y), 0, Vector2i(0, 1))
			elif tile_neg_x_diff == Vector2i(1,2):
				walls_floor_map.set_cell(Vector2i(y_x.x - x_diff, y), 0, Vector2i(0, 2))
			elif tile_neg_x_diff == Vector2i(4,3):
				walls_floor_map.set_cell(Vector2i(y_x.x - x_diff, y), 0, Vector2i(0, 0))
		
		walls_floor_map.set_cell(Vector2i(y_x.x, y), 0, Vector2i(1, 6))
		walls_floor_map.set_cell(Vector2i(y_x.x + x_diff, y), 0, Vector2i(1, 6))
		
func find_start_room():
	var min_x = INF
	for room in $Rooms.get_children():
		if room.position.x < min_x:
			min_x = room.position.x
			start_room = room

func find_end_room():
	var max_x = -INF
	for room in $Rooms.get_children():
		if room.position.x > max_x:
			max_x = room.position.x
			end_room = room	

func player_died():
	death.play()
	player_killed_score()
	store_era()
	store_corpse()
	era -= 1
	negative_eras += 1
	difficulty_modifier = min(difficulty_modifier - 1, 0)
	new_dungeon()
	
func player_passed():
	next_level.play()
	boss_killed_score()
	store_era()
	era += 1
	if negative_eras <= 0:
		difficulty_modifier += 1
	negative_eras -= 1	
	new_dungeon()

func store_era():
	if not eras_rooms.has(era):
		eras_paths[era] = []
		eras_paths[era].append(path)
		eras_paths[era].append(path_switch)
		eras_rooms[era] = []
		for room in $Rooms.get_children():
			eras_rooms[era].append([Vector2i(int(room.position.x),int(room.position.y)),room.size])

func store_corpse():
	if not eras_corpses.has(era):
		eras_corpses[era] = []
	eras_corpses[era].append([Vector2i(int(player.position.x),int(player.position.y)),
	player.health_potions,
	player.get_node("Rifle").picked,
	player.get_node("Rifle").ammo,
	player.get_node("Shotgun").picked,
	player.get_node("Shotgun").ammo,
	player.get_node("Sniper").picked,
	player.get_node("Sniper").ammo])
	for corpse in $Corpses.get_children():
		corpse.queue_free()

func delete_assets():
	var map_cam = self.get_node("Camera2D")
	if map_cam:
		map_cam.make_current()
	
	for camera in $minimap.get_children():
		camera.queue_free()
		
	player.queue_free()
	play_mode = false
	
	for e in $Enemies.get_children():
		e.queue_free()
	
	for o in $Objects.get_children():
		o.queue_free()	
		
	for n in $Rooms.get_children():
		n.queue_free()

func reset_vars():
	path = null
	path_switch = []
	switch_index = 0
	start_room = null
	end_room = null	
			
func new_dungeon():
	delete_assets()
	await(get_tree().create_timer(1.1).timeout)
	reset_vars()
		
	walls_floor_map.clear()
	
	if eras_rooms.has(era):
		path = eras_paths[era][0]
		path_switch = eras_paths[era][1]
		for values in eras_rooms[era]:
			var r = Room.instantiate()
			r.make_room(values[0],values[1])
			$Rooms.add_child(r) 

	else:	
		await make_rooms()
	await make_map()
	

func connect_slime_health_component(s):
	var slime_dead = s
	slime_dead.connect("enemy_killed", Callable(self, "_on_slime_killed"))
	
func connect_knight_health_component(k):
	var knight_dead = k
	knight_dead.connect("enemy_killed", Callable(self, "_on_knight_killed"))
	
func _on_slime_killed():
	high_score += 10 + int(10 * (difficulty_modifier / 5))
	emit_signal("high_score_changed", high_score)

func _on_knight_killed():
	high_score += 50 + int(10 * (difficulty_modifier / 5))
	emit_signal("high_score_changed", high_score)
	
func boss_killed_score():
	high_score += 500 + int(10 * (difficulty_modifier / 5))
	emit_signal("high_score_changed", high_score)
	
func player_killed_score():
	high_score -= 1000
	emit_signal("high_score_changed", high_score)

func save_score():
	var scores = load_scores()  # Load existing scores
	scores.append([save_name, high_score])  # Add the new one

	var file = FileAccess.open(savefile, FileAccess.WRITE)
	if file:
		file.store_var(scores)
		file.close()
	
func load_scores() -> Array:
	if not FileAccess.file_exists(savefile):
		return []

	var file = FileAccess.open(savefile, FileAccess.READ)
	if file == null:
		push_error("Failed to open save file.")
		return []

	var scores = file.get_var()
	file.close()

	# Make sure it's a valid list of scores
	if scores is Array:
		return scores
	else:
		return []
