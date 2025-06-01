extends Control

func _on_start_pressed() -> void:
	var loading_scene = load("res://Scenes/Main/main.tscn")
	get_tree().change_scene_to_packed(loading_scene)

func _on_options_pressed() -> void:
	print("options pressed")

func _on_exit_pressed() -> void:
	get_tree().quit()
