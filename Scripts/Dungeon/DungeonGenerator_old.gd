extends Node2D

const WIDTH = 200
const HEIGHT = 150
const CELL_SIZE = 10
const MIN_ROOM_SIZE = 20
const MAX_ROOM_SIZE = 40
const MAX_ROOMS = 20
const CORRIDOR_WIDTH = 4

var grid = []
var rooms = []

func _ready():
	randomize()
	initialize_grid()
	generate_dungeon()
	draw_dungeon()

func initialize_grid():
	for x in range(WIDTH):
		grid.append([])
		for y in range(HEIGHT):
			grid[x].append(-1) # represents a wall
			
func generate_dungeon():
	for i in range(MAX_ROOMS):
		var room = generate_room()
		if place_room(room):
			if rooms.size() > 0:
				connect_rooms(rooms[-1], room)
			rooms.append(room)
		
func generate_room():
	var width = randi() % (MAX_ROOM_SIZE - MIN_ROOM_SIZE + 1) + MIN_ROOM_SIZE
	var height = randi() % (MAX_ROOM_SIZE - MIN_ROOM_SIZE + 1) + MIN_ROOM_SIZE
	
	var x = randi() % (WIDTH - width - 1) + 1
	var y = randi() % (HEIGHT - height - 1) + 1
	
	return Rect2(x, y, width, height)
	
func place_room(room):
	for x in range(room.position.x, room.end.x):
		for y in range(room.position.y, room.end.y):
			if grid[x][y] == 0:
				return false
	
	for x in range(room.position.x, room.end.x):
		for y in range(room.position.y, room.end.y):
			grid[x][y] = 0
	
	return true
	
func connect_rooms(room1, room2):
	var start = Vector2(int(room1.position.x + room1.size.x / 2),int(room1.position.y + room1.size.y / 2))
	var end	= Vector2(int(room2.position.x + room2.size.x / 2),int(room2.position.y + room2.size.y / 2))
	
	var current = start
	
	while current.x != end.x:
		current.x += 1 if end.x > current.x else -1
		for i in range(-int(CORRIDOR_WIDTH / 2), int(CORRIDOR_WIDTH / 2) + 1):
			for j in range(-int(CORRIDOR_WIDTH / 2), int(CORRIDOR_WIDTH / 2) + 1):
				if current.y + j >= 0 and current.y + j < HEIGHT and current.x + i >= 0 and current.x + i  < WIDTH:
					if(grid[current.x + i][current.y + j] == -1):
						grid[current.x + i][current.y + j] = 1
					
	while current.y != end.y:
		current.y += 1 if end.y > current.y else -1
		for i in range(-int(CORRIDOR_WIDTH / 2), int(CORRIDOR_WIDTH / 2) + 1):
			for j in range(-int(CORRIDOR_WIDTH / 2), int(CORRIDOR_WIDTH / 2) + 1):
				if current.x + i >= 0 and current.x + i < WIDTH and current.y + j >= 0 and current.y + j  < HEIGHT:
					if(grid[current.x + i][current.y + j] == -1):
						grid[current.x + i][current.y + j] = 1			
	
func draw_dungeon():
	for x in range(WIDTH):
		for y in range(HEIGHT):
			var cell = ColorRect.new()
			cell.size = Vector2(CELL_SIZE, CELL_SIZE)
			cell.position = Vector2(x * CELL_SIZE, y * CELL_SIZE)
			if grid[x][y] == 0:
				cell.color = Color.WHITE 
			elif grid[x][y] == 1:
				cell.color = Color.BLUE 
			else: 
				cell.color = Color.BLACK
			add_child(cell)
			
