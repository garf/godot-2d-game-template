class_name PlayerVitalsController extends Node

enum State { ALIVE, DEAD }

var state: State = State.ALIVE

@onready var _player: Player = get_parent() as Player
@onready var _hp_comp: HpComp = $HpComp


func _enter_tree() -> void:
	Events.PLAYER_death_requested.connect(_on_death_requested)
	Events.PLAYER_respawn_requested.connect(_on_respawn_requested)
	Events.VIEW_view_loaded.connect(_on_view_loaded)


func _ready() -> void:
	_hp_comp.hp_changed.connect(_on_hp_changed)
	_hp_comp.hp_depleted.connect(_on_hp_depleted)


func _exit_tree() -> void:
	if Events.PLAYER_death_requested.is_connected(_on_death_requested):
		Events.PLAYER_death_requested.disconnect(_on_death_requested)
	if Events.PLAYER_respawn_requested.is_connected(_on_respawn_requested):
		Events.PLAYER_respawn_requested.disconnect(_on_respawn_requested)
	if Events.VIEW_view_loaded.is_connected(_on_view_loaded):
		Events.VIEW_view_loaded.disconnect(_on_view_loaded)

	if _hp_comp.hp_changed.is_connected(_on_hp_changed):
		_hp_comp.hp_changed.disconnect(_on_hp_changed)
	if _hp_comp.hp_depleted.is_connected(_on_hp_depleted):
		_hp_comp.hp_depleted.disconnect(_on_hp_depleted)


func receive_damage(amount: float) -> float:
	if is_dead():
		return _hp_comp.hp

	return _hp_comp.deal_damage(amount)


func die() -> void:
	if is_dead():
		return

	state = State.DEAD
	_hp_comp.set_hp(0.0)
	Events.PLAYER_died.emit()


func respawn(global_position: Vector2) -> void:
	state = State.ALIVE
	_player.global_position = global_position
	_player.velocity = Vector2.ZERO
	_hp_comp.heal_full()
	Events.PLAYER_respawned.emit(global_position)


func is_alive() -> bool:
	return state == State.ALIVE


func is_dead() -> bool:
	return state == State.DEAD


func _emit_hp_changed(old_hp: float) -> void:
	Events.PLAYER_hp_changed.emit(_hp_comp.hp, _hp_comp.max_hp, old_hp)


func _on_death_requested() -> void:
	die()


func _on_respawn_requested(global_position: Vector2) -> void:
	respawn(global_position)


func _on_view_loaded(view: ViewDb.Keys) -> void:
	if view != ViewDb.Keys.GAME:
		return

	_emit_hp_changed(_hp_comp.hp)


func _on_hp_changed(_current_hp: float, old_hp: float) -> void:
	_emit_hp_changed(old_hp)


func _on_hp_depleted() -> void:
	die()
