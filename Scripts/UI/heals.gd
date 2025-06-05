extends Label

func _ready():
	pass
	
	
func connect_player(p):
	var player = p
	player.connect("health_potions_changed", Callable(self, "_on_health_potions_changed"))
	self.text = str(player.health_potions)

func _on_health_potions_changed(value: int):
	self.text = str(value)
