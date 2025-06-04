class_name HealthComponent
extends Node2D

@export var max_health: float = 100.0
var current_health: float

signal health_changed(current: float)
signal died

func _ready() -> void:
	current_health = max_health
	emit_signal("health_changed", current_health)

func heal(amount: float) -> void:
	if amount <= 0.0 or current_health == max_health:
		return

	current_health = min(current_health + amount, max_health)
	emit_signal("health_changed", current_health)

func damage(attack: Attack) -> void:
	current_health -= attack.attack_damage
	emit_signal("health_changed", current_health)

	if current_health <= 0.0:
		emit_signal("died")
		var parent = get_parent()
		if not parent.is_in_group("player"):
			if not parent.is_in_group("boss"):
				die()
			else:
				get_tree().call_group("player_died", "boss_died")
				die()
		else:
			get_tree().call_group("player_died", "i_died")

func die() -> void:
	get_parent().queue_free()
