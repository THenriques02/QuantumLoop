extends CharacterBody2D

var item_type = "corpse_loot"
var shotgun = false
var rifle = false
var sniper = false
var rifle_ammo = 0
var sniper_ammo = 0
var shotgun_ammo = 0
var health_potions = 0

func _ready():
	pass
	
func set_shotgun(t):
	shotgun = t

func set_rifle(t):
	rifle = t
	
func set_sniper(t):
	sniper = t	

func set_rifle_ammo(n):
	rifle_ammo = n 
	
func set_shotgun_ammo(n):
	shotgun_ammo = n 
	
func set_sniper_ammo(n):
	sniper_ammo = n
	
func set_health_potions(n):
	health_potions = n	
