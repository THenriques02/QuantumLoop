extends Control

func _on_start_pressed() -> void:
	var loading_scene = load("res://Scenes/Main/main.tscn")
	get_tree().change_scene_to_packed(loading_scene)

func _on_high_scores_pressed() -> void:
	var loading_scene = load("res://Scenes/UI/High_scores.tscn")
	get_tree().change_scene_to_packed(loading_scene)

func _on_exit_pressed() -> void:
	get_tree().quit()
