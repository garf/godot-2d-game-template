class_name Player extends CharacterBody2D


signal facing_direction_changed(facing_direction: Vector2)

const HIT_FLASH_TIME: float = 0.1

var facing_sign: int = 1
var facing_direction: Vector2 = Vector2.RIGHT
var _hit_flash_id: int = 0

@onready var _sprite: AnimatedSprite2D = $PlayerSprites
@onready var _movement_controller: PlayerMovementController = $MovementController
@onready var _vitals_controller: PlayerVitalsController = $VitalsController
@onready var _camera: Camera2D = $Camera2D


func _enter_tree() -> void:
	Events.PLAYER_died.connect(_on_player_died)
	Events.PLAYER_respawned.connect(_on_player_respawned)


func _exit_tree() -> void:
	if Events.PLAYER_died.is_connected(_on_player_died):
		Events.PLAYER_died.disconnect(_on_player_died)
	if Events.PLAYER_respawned.is_connected(_on_player_respawned):
		Events.PLAYER_respawned.disconnect(_on_player_respawned)


func _ready() -> void:
	_sync_facing_visuals()
	_sprite.play(&"idle_right")


func _physics_process(delta: float) -> void:
	_movement_controller.physics_update(delta)
	if is_dead():
		return

	_update_animation()


func set_facing_sign(value: int) -> void:
	var next_facing_sign: int = 1
	if value < 0:
		next_facing_sign = -1
	elif value == 0:
		return

	if facing_sign == next_facing_sign:
		return

	facing_sign = next_facing_sign
	facing_direction = Vector2(float(facing_sign), 0.0)
	_sync_facing_visuals()
	facing_direction_changed.emit(facing_direction)


func get_facing_direction() -> Vector2:
	return facing_direction


func receive_damage(amount: float) -> float:
	return _vitals_controller.receive_damage(amount)


func receive_hit(damage: float, source_position: Vector2, _hitbox: HitboxComp) -> void:
	if is_dead():
		return

	var current_hp: float = receive_damage(damage)
	if current_hp <= 0.0 or is_dead():
		return

	_play_hit_reaction(source_position)


func die() -> void:
	_vitals_controller.die()


func respawn(spawn_global_position: Vector2) -> void:
	_vitals_controller.respawn(spawn_global_position)


func is_alive() -> bool:
	return _vitals_controller.is_alive()


func is_dead() -> bool:
	return _vitals_controller.is_dead()


func _sync_facing_visuals() -> void:
	_sprite.flip_h = facing_sign < 0


func _update_animation() -> void:
	if _sprite.animation == &"hit_right" and _sprite.is_playing():
		return

	var next_animation: StringName = &"idle_right"

	if not is_on_floor():
		next_animation = &"jump_right"
	elif _movement_controller.is_crouching():
		next_animation = &"crouch_right"
	elif absf(velocity.x) > 5.0:
		next_animation = &"walk_right"

	_play_animation(next_animation)


func _play_animation(animation: StringName, force_restart: bool = false) -> void:
	if _sprite.animation == animation and not force_restart:
		return

	_sprite.play(animation)


func _play_hit_reaction(source_position: Vector2) -> void:
	var away_sign: float = signf(global_position.x - source_position.x)
	if is_zero_approx(away_sign):
		away_sign = float(facing_sign)

	_play_animation(&"hit_right", true)
	_flash_hit_shader()
	_movement_controller.start_hit_reaction(away_sign)


func _flash_hit_shader() -> void:
	_hit_flash_id += 1
	var current_flash_id: int = _hit_flash_id
	_set_hit_shader_active(true)

	await get_tree().create_timer(HIT_FLASH_TIME).timeout
	if current_flash_id != _hit_flash_id:
		return

	_set_hit_shader_active(false)


func _set_hit_shader_active(active: bool) -> void:
	var hit_material: ShaderMaterial = _sprite.material as ShaderMaterial
	if hit_material == null:
		return

	hit_material.set_shader_parameter(&"active", active)


func _stop_camera_following() -> void:
	var camera_global_position: Vector2 = _camera.global_position
	_camera.top_level = true
	_camera.global_position = camera_global_position


func _restore_camera_following() -> void:
	_camera.top_level = false
	_camera.position = Vector2.ZERO


func _on_player_died() -> void:
	_set_hit_shader_active(false)
	_play_animation(&"death_right", true)
	_stop_camera_following()


func _on_player_respawned(_spawn_global_position: Vector2) -> void:
	_hit_flash_id += 1
	_set_hit_shader_active(false)
	_restore_camera_following()
	_sync_facing_visuals()
	_play_animation(&"idle_right", true)
