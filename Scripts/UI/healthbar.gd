extends ProgressBar

@onready var timer = $Timer
@onready var damage_bar = $DamageBar

var health: float = 0.0
var max_health: float = 100.0

@onready var health_component: HealthComponent = null

func _ready() -> void:
	# Attempt to find the HealthComponent in the parent or self
	health_component = get_parent().get_node_or_null("HealthComponent")
	if health_component:
		max_health = health_component.max_health
		max_value = max_health
		health = max_health
		value = health
		damage_bar.max_value = max_health
		damage_bar.value = health
		
		health_component.connect("health_changed", Callable(self, "_on_health_changed"))
		health_component.connect("died", Callable(self, "_on_died"))
	else:
		# fallback if no HealthComponent found
		max_value = 100
		health = 100
		value = health
		damage_bar.max_value = max_value
		damage_bar.value = health

func _on_health_changed(current_health: float) -> void:
	var prev_health = health
	health = current_health
	value = health
	
	if health < prev_health:
		timer.start()
	else:
		damage_bar.value = health

	if health <= 0:
		queue_free()

func _on_died() -> void:
	queue_free()

func _on_timer_timeout() -> void:
	damage_bar.value = health
	
func set_health_component(comp):
	damage_bar = $DamageBar
	timer = $Timer
	health_component = comp
	max_health = health_component.max_health
	max_value = max_health
	health = max_health
	value = health
	damage_bar.max_value = max_health
	damage_bar.value = health
	
	health_component.connect("health_changed", Callable(self, "_on_health_changed"))
	health_component.connect("died", Callable(self, "_on_died"))
