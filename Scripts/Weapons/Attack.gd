class_name Attack extends Resource

var attack_damage: float
var knockback_force: float
var stun_time: float
var attack_pos: Vector2

func configure(damage: float, knockback: float, stun: float, pos: Vector2) -> Attack:
	attack_damage = damage
	knockback_force = knockback
	stun_time = stun
	attack_pos = pos
	return self
