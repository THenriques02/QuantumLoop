extends Label

func _ready():
	pass
	
func connect_main(m):
	var main = m
	main.connect("high_score_changed", Callable(self, "_on_high_score_changed"))
	self.text = str(main.high_score)

func _on_high_score_changed(value: int):
	self.text = str(value)
