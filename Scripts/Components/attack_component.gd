class_name AttackComponent
extends Area2D

@export var attack_damage: float = 10.0
@export var knockback_force: float = 100.0
@export var stun_time: float = 1.5
@export var is_projectile: bool = false  # Set to true for bullets/projectiles

func _ready() -> void:
	area_entered.connect(_on_hitbox_area_entered)

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area is HitboxComponent:
		var attack = Attack.new()
		attack.attack_damage = attack_damage
		attack.knockback_force = knockback_force
		attack.stun_time = stun_time
		attack.attack_pos = global_position

		area.damage(attack)

		if is_projectile:
			get_parent().queue_free()
