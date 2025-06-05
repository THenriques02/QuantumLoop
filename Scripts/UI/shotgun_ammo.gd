extends Label

func _ready():
	pass
	
func connect_shotgun(s):
	var shotgun = s
	shotgun.connect("shotgun_ammo_changed", Callable(self, "_on_shotgun_ammo_changed"))
	self.text = str(shotgun.ammo)

func _on_shotgun_ammo_changed(value: int):
	self.text = str(value)
