class_name PickupComponent
extends Area2D

func _ready() -> void:
	area_entered.connect(_on_hitbox_area_entered)

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area is HitboxComponent:
		var loot = get_parent().item_type
		if loot == "ammo":
			print("send1")
			get_tree().call_group("picked_loot","picked_ammo")
		elif loot == "health_potion":
			print("send2")
			get_tree().call_group("picked_loot","picked_health")
		get_parent().queue_free()
