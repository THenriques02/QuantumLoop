extends Camera2D

@export var move_speed := 2000.0
@export var zoom_speed := 0.1
@export var min_zoom := 0.1
@export var max_zoom := 3.0

func _process(delta: float) -> void:
	var input_dir = Vector2.ZERO
	input_dir.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_dir.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")

	if input_dir != Vector2.ZERO:
		position += input_dir.normalized() * move_speed * delta

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			zoom_camera(-zoom_speed)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			zoom_camera(zoom_speed)

func zoom_camera(delta_zoom: float) -> void:
	var new_zoom = zoom + Vector2.ONE * delta_zoom
	new_zoom.x = clamp(new_zoom.x, min_zoom, max_zoom)
	new_zoom.y = clamp(new_zoom.y, min_zoom, max_zoom)
	zoom = new_zoom
