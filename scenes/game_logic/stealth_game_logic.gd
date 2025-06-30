# SPDX-FileCopyrightText: The Threadbare Authors
# SPDX-License-Identifier: MPL-2.0
@tool
class_name StealthGameLogic
extends Node

@export_range(0.5, 3.0, 0.1, "or_greater", "or_less") var zoom: float = 1.0:
	set = _set_zoom
	
@onready var player: Player = get_tree().get_first_node_in_group("player")


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	_set_zoom(zoom)
	for guard: Guard in get_tree().get_nodes_in_group(&"guard_enemy"):
		guard.player_detected.connect(self._on_player_detected)
	
	if player:
		player.mode = Player.Mode.FIGHTING
		
	get_tree().call_group("throwing_enemy", "start")
	%CollectibleItem.revealed = true
	
func _process(delta: float) -> void:
	# Asegúrate de que el jugador esté listo
	if not player:
		return

	# Umbral en píxeles
	const UMBRAL_COZY := 5520

	# Cuando la posición X del jugador supera el umbral...
	if player.global_position.x > UMBRAL_COZY:
		player.mode = Player.Mode.COZY
		# (Opcional) para volver a otro modo si regresa
	elif player.global_position.x <= UMBRAL_COZY:
		player.mode = Player.Mode.FIGHTING


func _on_player_detected(player: Node2D) -> void:
	player.mode = Player.Mode.DEFEATED
	await get_tree().create_timer(2.0).timeout
	SceneSwitcher.reload_with_transition(Transition.Effect.FADE, Transition.Effect.FADE)


func _set_zoom(new_value: float) -> void:
	zoom = new_value
	if Engine.is_editor_hint():
		return
	if not is_node_ready():
		return
	var camera: Camera2D = get_viewport().get_camera_2d()
	camera.zoom = Vector2.ONE * zoom
