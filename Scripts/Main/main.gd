extends Node2D

var Room = preload("res://Scenes/Dungeon/Room.tscn")
var font = preload("res://Assets/Dungeon/Roboto-VariableFont_wdth,wght.ttf")
var Player = preload("res://Scenes/Player/player.tscn")
var Corpse = preload("res://Scenes/Dungeon/corpse.tscn")
var Ui = preload("res://Scenes/UI/control.tscn")
var Slime = preload("res://Scenes/Enemies/slime.tscn")
var Chest = preload("res://Scenes/Dungeon/chest.tscn")
var ui_instance
@onready var walls_floor_map = $Walls_Floor



var tile_size = 16 # size of tile in the TileMap
var margin_tiles = 500
var num_rooms = 100 # numer of rooms to generate
var min_size = 20   # minimum room size ( in tiles)
var max_size = 40  # maximum room size (in tiles )
var hspread = 20   # horizontal spread ( in pixels )
var cull = 0.5     # chance to cull the room
var seed = randi()

var path           # AStar pathfinding object
var start_room = null
var end_room = null
var play_mode = null
var player = null

var era = 0
var eras_rooms = {}
var eras_paths = {}
var path_switch = []
var switch_index = 0
var eras_corpses = {}

func _ready():
	randomize()
	await make_rooms()
	await make_map()
	$Background.visible = false
	$Maintext.visible = false
	$Subtext.visible = false
	
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
	"""
	if event.is_action_pressed('ui_select'):
		if play_mode:
			var map_cam = self.get_node("Camera2D")
			if map_cam:
				map_cam.make_current()
			
			player.queue_free()
			play_mode = false
		for n in $Rooms.get_children():
			n.queue_free()
		path = null
		start_room = null
		end_room = null	
		make_rooms()

	if event.is_action_pressed(('ui_focus_next')):
		make_map()
	"""	
	if event.is_action_pressed("ui_page_down"):
		$Maintext.text = "You Died"
		$Subtext.text = "Forward to the Past"
		$Background.visible = true
		$Maintext.visible = true
		$Subtext.visible = true
		player_died()
	if event.is_action_pressed("ui_page_up"):
		$Maintext.text = "You Survived"
		$Subtext.text = "Back to the Future"
		$Background.visible = true
		$Maintext.visible = true
		$Subtext.visible = true
		player_passed()	
	if event.is_action_pressed('ui_cancel'):
		get_tree().quit()		
	if event.is_action_pressed('ui_accept'):
		for room in $Rooms.get_children():
			room.get_node("CollisionShape2D").disabled = true
			for e in range(randi_range(3, 8)):
				var slime = Slime.instantiate()
				slime.position = room.position
				$Enemies.add_child(slime)
			
			for a in range(1):
				var asset = Chest.instantiate()
				asset.position = room.position 
				$Objects.add_child(asset)
				
		player = Player.instantiate()
		add_child(player)
		player.position = start_room.position
		
		if eras_corpses.has(era):
			for c_pos in eras_corpses[era]:
				var corpse = Corpse.instantiate()
				corpse.position = c_pos
				$Corpses.add_child(corpse)
		
		await get_tree().create_timer(0.1).timeout
		
		var cam = player.get_node("Camera2D")
		if cam:
			cam.make_current()
		
		var map_cam = self.get_node("Camera2D")	
		ui_instance = Ui.instantiate()
		ui_instance.get_node("UI/SubViewportContainer/SubViewport").set_player(player)
		ui_instance.get_node("UI/SubViewportContainer/SubViewport").set_world(get_tree().root.world_2d)
		$minimap.add_child(ui_instance)

		play_mode = true	


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
	
	$Background.visible = false
	$Maintext.visible = false
	$Subtext.visible = false
						 
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
	store_era()
	store_corpse()
	era -= 1
	new_dungeon()
	
func player_passed():
	store_era()
	era += 1
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
	eras_corpses[era].append(player.position)
	for corpse in $Corpses.get_children():
		corpse.queue_free()
			
func new_dungeon():
	if play_mode:
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
		n.get_node("CollisionShape2D").disabled = false
		n.freeze = false
		n.queue_free()
	path = null
	path_switch = []
	switch_index = 0
	start_room = null
	end_room = null	
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
