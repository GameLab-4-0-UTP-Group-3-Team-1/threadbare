class_name CustomPlayer extends Player

@export var duration_animation_sword: float = .3
@export var start_live: float = 100

@onready var sword_area: Area2D = $SwordArea2D
@export var sword_offset: Vector2 = Vector2(32, 0)

var can_attack: bool = true
var health: float = start_live

func _ready() -> void:
	super._ready()
	sword_area.body_entered.connect(_on_sword_area_body_entered)
	sword_area.monitoring = false
	_update_sword_area_position()

func _process(delta: float) -> void:
	super._process(delta)
	_update_sword_area_position()
	if Input.is_action_just_pressed("ui_accept") and can_attack:
		_do_attack()

func _do_attack() -> void:
	can_attack = false
	
	sword_area.monitoring = true
	
	await get_tree().create_timer(duration_animation_sword).timeout
	sword_area.monitoring = false
	can_attack = true

func swing_sword() -> void:
	sword_area.monitoring = true

func stop_swing_sword() -> void:
	sword_area.monitoring = false

func _on_sword_area_body_entered(body: Node) -> void:
	if body.is_in_group("guard_enemy"):
		var enemy := body as CustomGuard
		if enemy:
			enemy.remove()
	
	if body is CustomArrow:
		var arrow := body as CustomArrow
		if arrow:
			arrow.got_hit(owner)
	
	if body is CustomThrowingEnemy:
		var archer := body as CustomThrowingEnemy
		archer.remove()

func recive_damage(lost_live = 0) -> void:
	health -= lost_live
	if health <= 0:
		print("Player debe morir")
		
func _is_facing_right() -> bool:
	return not $PlayerSprite.flip_h
	
func _update_sword_area_position():
	var dir = 1 if _is_facing_right() else -1
	sword_area.position = Vector2(sword_offset.x * dir, sword_offset.y)
	sword_area.rotation = PI if dir == -1 else 0
