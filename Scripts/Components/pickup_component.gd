class_name PickupComponent
extends Area2D

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
		get_parent().queue_free()
