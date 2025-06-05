extends Control

const savefile = "user://savefile.save"

func _ready():
	display_top_scores()


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
		
func display_top_scores():
	var scores = load_scores()
	print(scores)
	
	# Sort scores by score value in descending order
	if scores.is_empty():
		$Scores.text = "No High Scores."
		return
	
	if scores.size() > 1:
		scores.sort_custom(func(a, b): return a[1] > b[1])

	var output_text = ""
	for i in range(min(10, scores.size())):
		var entry = scores[i]
		output_text += "%s: %d\n" % [entry[0], entry[1]]

	$Scores.text = output_text		
		
func _on_back_pressed() -> void:
	var loading_scene = load("res://Scenes/UI/main_menu.tscn")
	get_tree().change_scene_to_packed(loading_scene)
