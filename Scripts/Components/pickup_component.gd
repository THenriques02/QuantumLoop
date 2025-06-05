class_name PickupComponent
extends Area2D

@onready var skelly: AudioStreamPlayer2D = $Skelly

func _ready() -> void:
	area_entered.connect(_on_hitbox_area_entered)

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area is HitboxComponent:
		var loot = get_parent().item_type
		
		if loot == "ammo":
			get_tree().call_group("picked_loot","picked_ammo_shotgun")
			get_tree().call_group("picked_loot","picked_ammo_sniper")
			get_tree().call_group("picked_loot","picked_ammo_rifle")
			
		elif loot == "health_potion":
			get_tree().call_group("picked_loot","picked_health")
			
		elif loot == "shotgun":
			get_tree().call_group("picked_loot","picked_shotgun")
			get_tree().call_group("picked_loot","picked_ammo_shotgun")
			
		elif loot == "rifle":
			get_tree().call_group("picked_loot","picked_rifle")
			get_tree().call_group("picked_loot","picked_ammo_rifle")	
			
		elif loot == "sniper":
			get_tree().call_group("picked_loot","picked_sniper")
			get_tree().call_group("picked_loot","picked_ammo_sniper")
			get_tree().call_group("picked_loot","picked_ammo_rifle")

		elif loot == "sniper":
			get_tree().call_group("picked_loot","picked_sniper")
			get_tree().call_group("picked_loot","picked_ammo_sniper")

			
		elif loot == "corpse_loot":
			var health_potions = get_parent().health_potions
			var rifle_ammo = get_parent().rifle_ammo
			var shotgun_ammo = get_parent().shotgun_ammo	
			var sniper_ammo = get_parent().sniper_ammo
			
			if get_parent().rifle:
				get_tree().call_group("picked_loot","picked_rifle")
				
			if get_parent().shotgun:
				get_tree().call_group("picked_loot","picked_shotgun")
				
			if get_parent().sniper:
				get_tree().call_group("picked_loot","picked_sniper")
				
			while health_potions >= 1:
				get_tree().call_group("picked_loot","picked_health")
				health_potions -= 1
				
			while rifle_ammo >= 32:
				get_tree().call_group("picked_loot","picked_ammo_rifle")
				rifle_ammo -= 32
				
			while shotgun_ammo >= 6:
				get_tree().call_group("picked_loot","picked_ammo_shotgun")
				shotgun_ammo -= 6
				
			while sniper_ammo >= 8:
				get_tree().call_group("picked_loot","picked_ammo_sniper")
				sniper_ammo -= 8		
								
		get_parent().queue_free()
