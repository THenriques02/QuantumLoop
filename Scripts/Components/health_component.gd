class_name HealthComponent
extends Node2D

@export var max_health: float = 100.0
var current_health: float

signal health_changed(current: float)
signal died

func _ready() -> void:
	current_health = max_health

func damage(attack: Attack) -> void:
	current_health -= attack.attack_damage
	emit_signal("health_changed", current_health)

	if current_health <= 0:
		emit_signal("died")
		die()

func die() -> void:
	get_parent().queue_free()
