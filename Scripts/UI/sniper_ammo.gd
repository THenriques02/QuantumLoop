extends Label

func _ready():
	pass
	
func connect_sniper(s):
	var sniper = s
	sniper.connect("sniper_ammo_changed", Callable(self, "_on_sniper_ammo_changed"))
	self.text = str(sniper.ammo)

func _on_sniper_ammo_changed(value: int):
	self.text = str(value)
