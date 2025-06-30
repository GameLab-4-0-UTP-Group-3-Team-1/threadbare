class_name CustomGuard extends Guard

@export var max_health: float = 100
var health: float = max_health

@export var duration_animation_defeated: float = 0.5

func recive_damage(lost_live = 0) -> void:
	health -= lost_live
	if health <= 0:
		self.remove()

func remove()  -> void:
	sprite.play(&"defeated")
	await get_tree().create_timer(duration_animation_defeated).timeout
	
	set_physics_process(false)
	self.queue_free()
