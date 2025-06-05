extends Label

func _ready():
	pass
	
func connect_rifle(r):
	var rifle = r
	rifle.connect("rifle_ammo_changed", Callable(self, "_on_rifle_ammo_changed"))
	self.text = str(rifle.ammo)

func _on_rifle_ammo_changed(value: int):
	self.text = str(value)
