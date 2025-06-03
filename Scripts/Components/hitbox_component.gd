class_name HitboxComponent
extends Area2D

@export_node_path("HealthComponent") var health_path: NodePath
var health_component: HealthComponent

signal damaged(attack: Attack)

func _ready() -> void:
	if health_path:
		health_component = get_node(health_path) as HealthComponent
	else:
		push_warning("No HealthComponent assigned to HitboxComponent.")

func damage(attack: Attack) -> void:
	if health_component and attack:
		health_component.damage(attack)
		emit_signal("damaged", attack)
