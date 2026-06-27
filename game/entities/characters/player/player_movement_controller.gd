class_name PlayerMovementController extends Node


@export var max_walk_speed: float = 120.0
@export var ground_acceleration: float = 1800.0
@export var ground_deceleration: float = 2200.0
@export var air_acceleration: float = 1100.0
@export var air_deceleration: float = 700.0
@export var turn_acceleration: float = 2600.0
@export var jump_velocity: float = -330.0
@export var gravity: float = 950.0
@export var fall_gravity: float = 1250.0
@export var max_fall_speed: float = 700.0
@export var coyote_time: float = 0.10
@export var jump_buffer_time: float = 0.10
@export var jump_cut_multiplier: float = 0.45
@export var max_jumps: int = 2
@export var crouch_speed_multiplier: float = 0.45
@export var slide_speed_multiplier: float = 1.25
@export var slide_min_start_speed: float = 20.0
@export var slide_jump_velocity_multiplier: float = 1.15
@export var slide_flat_time: float = 0.20
@export var slide_slowdown_time: float = 0.35
@export var slide_jump_bonus_end_offset: float = 0.08
@export var hit_launch_strength: float = 240.0
@export var climb_speed: float = 70.0
@export var climb_detach_horizontal_speed: float = 120.0
@export var climb_probe_offset: Vector2 = Vector2(0.0, -4.0)

var _crouching: bool = false
var _climbing: bool = false
var _climb_moving: bool = false
var _sliding: bool = false
var _slide_timer: float = 0.0
var _coyote_timer: float = 0.0
var _jump_buffer_timer: float = 0.0
var _remaining_air_jumps: int = 0
var _was_on_floor: bool = false
var _hit_air_control_locked: bool = false
var _hit_air_control_was_airborne: bool = false

@onready var _player: Player = get_parent() as Player


func physics_update(delta: float) -> void:
	if _player.is_dead():
		_clear_control_state()
		_apply_dead_movement(delta)
		_was_on_floor = _player.is_on_floor()
		return

	var on_floor: bool = _player.is_on_floor()
	var just_landed: bool = on_floor and not _was_on_floor
	if _hit_air_control_locked and not on_floor:
		_hit_air_control_was_airborne = true
	elif _hit_air_control_locked and _hit_air_control_was_airborne and on_floor:
		_hit_air_control_locked = false
		_hit_air_control_was_airborne = false

	var input_axis: float = Input.get_axis("walk_left", "walk_right")
	var climb_axis: float = Input.get_axis("move_up", "move_down")

	_update_timers(delta, on_floor)
	if _can_unlock_hit_air_control_for_jump(on_floor):
		_unlock_hit_air_control()

	if not _hit_air_control_locked:
		_update_facing(input_axis)
		_update_climb_state(climb_axis)
		if _climbing and not is_zero_approx(input_axis):
			_detach_from_climb(input_axis)

	if _climbing:
		_apply_climb_movement(climb_axis, delta)
		_apply_jump()
		_apply_jump_cut()
		_player.move_and_slide()
		if _player.is_on_floor() and climb_axis >= 0.0:
			_stop_climb()
		_was_on_floor = on_floor
		return

	_update_crouch(delta, on_floor, just_landed)
	if not _hit_air_control_locked:
		_apply_horizontal_movement(input_axis, delta, on_floor)
	_apply_jump()
	_apply_gravity(delta)
	_apply_jump_cut()

	_player.move_and_slide()
	_was_on_floor = on_floor


func is_crouching() -> bool:
	return _crouching


func is_climbing() -> bool:
	return _climbing


func is_climbing_moving() -> bool:
	return _climb_moving


func start_hit_reaction(launch_direction_sign: float) -> void:
	_clear_control_state()
	var launch_strength: float = maxf(hit_launch_strength, 0.0)
	_player.velocity = Vector2(launch_strength * launch_direction_sign, -launch_strength)
	_remaining_air_jumps = _get_available_air_jumps()
	_hit_air_control_locked = true
	_hit_air_control_was_airborne = false


func _apply_dead_movement(delta: float) -> void:
	if _player.is_on_floor() and _player.velocity.y >= 0.0:
		_player.velocity = Vector2.ZERO
		return

	_apply_gravity(delta)
	_player.move_and_slide()

	if _player.is_on_floor():
		_player.velocity = Vector2.ZERO


func _update_timers(delta: float, on_floor: bool) -> void:
	if on_floor:
		_coyote_timer = coyote_time
		_remaining_air_jumps = _get_available_air_jumps()
	else:
		_coyote_timer = maxf(_coyote_timer - delta, 0.0)

	if Input.is_action_just_pressed("jump"):
		_jump_buffer_timer = jump_buffer_time
	else:
		_jump_buffer_timer = maxf(_jump_buffer_timer - delta, 0.0)


func _update_facing(input_axis: float) -> void:
	if input_axis > 0.0:
		_player.set_facing_sign(1)
	elif input_axis < 0.0:
		_player.set_facing_sign(-1)


func _update_crouch(delta: float, on_floor: bool, just_landed: bool) -> void:
	if not on_floor or not Input.is_action_pressed("crouch"):
		_crouching = false
		_stop_slide()
		return

	_crouching = true
	var can_start_slide: bool = Input.is_action_just_pressed("crouch") or just_landed
	if can_start_slide and absf(_player.velocity.x) >= slide_min_start_speed:
		_sliding = true
		_slide_timer = 0.0
	elif _sliding:
		_slide_timer += delta
		if _slide_timer >= _get_slide_duration():
			_stop_slide()


func _apply_horizontal_movement(input_axis: float, delta: float, on_floor: bool) -> void:
	var speed_multiplier: float = _get_speed_multiplier()
	var target_speed: float = input_axis * max_walk_speed * speed_multiplier
	var acceleration: float = _get_horizontal_acceleration(input_axis, target_speed, on_floor)

	_player.velocity.x = move_toward(_player.velocity.x, target_speed, acceleration * delta)


func _get_speed_multiplier() -> float:
	if _sliding:
		return _get_slide_speed_multiplier()
	if _crouching:
		return crouch_speed_multiplier

	return 1.0


func _get_slide_speed_multiplier() -> float:
	if _slide_timer <= slide_flat_time:
		return slide_speed_multiplier
	if slide_slowdown_time <= 0.0:
		return crouch_speed_multiplier

	var slowdown_elapsed: float = _slide_timer - slide_flat_time
	var slowdown_progress: float = clampf(slowdown_elapsed / slide_slowdown_time, 0.0, 1.0)
	return lerpf(slide_speed_multiplier, crouch_speed_multiplier, slowdown_progress)


func _get_horizontal_acceleration(input_axis: float, target_speed: float, on_floor: bool) -> float:
	if is_zero_approx(input_axis):
		return ground_deceleration if on_floor else air_deceleration

	var is_turning: bool = not is_zero_approx(_player.velocity.x) and signf(_player.velocity.x) != signf(target_speed)
	if is_turning:
		return turn_acceleration

	return ground_acceleration if on_floor else air_acceleration


func _update_climb_state(climb_axis: float) -> void:
	if _climbing:
		if not _is_on_climbable_tile():
			_stop_climb()
		return

	if is_zero_approx(climb_axis) or not _is_on_climbable_tile():
		return

	_start_climb()


func _start_climb() -> void:
	_climbing = true
	_climb_moving = false
	_crouching = false
	_stop_slide()
	_coyote_timer = 0.0
	_player.velocity = Vector2.ZERO


func _stop_climb() -> void:
	_climbing = false
	_climb_moving = false


func _detach_from_climb(horizontal_axis: float) -> void:
	_stop_climb()
	_coyote_timer = coyote_time
	_remaining_air_jumps = _get_available_air_jumps()
	_player.velocity.x = horizontal_axis * climb_detach_horizontal_speed
	_player.velocity.y = 0.0


func _apply_climb_movement(climb_axis: float, delta: float) -> void:
	var climb_map: LevelTileMap = _player.get_climb_map()
	if climb_map == null:
		_stop_climb()
		return

	var climb_tile_center: Vector2 = climb_map.get_climb_tile_center_at_world_position(_get_climb_probe_position())
	var climb_velocity: float = climb_axis * climb_speed
	if climb_axis < 0.0 and not climb_map.is_climbable_at_world_position(
		_get_climb_probe_position() + Vector2(0.0, climb_velocity * delta)
	):
		climb_velocity = 0.0

	_player.global_position.x = climb_tile_center.x
	_player.velocity.x = 0.0
	_player.velocity.y = climb_velocity
	_climb_moving = not is_zero_approx(climb_velocity)


func _apply_jump() -> void:
	if _jump_buffer_timer <= 0.0 or max_jumps <= 0:
		return
	if _crouching and not _sliding:
		return

	if _climbing:
		_player.velocity.y = jump_velocity
		_jump_buffer_timer = 0.0
		_coyote_timer = 0.0
		_remaining_air_jumps = _get_available_air_jumps()
		_stop_climb()
		return

	var can_use_ground_jump: bool = _coyote_timer > 0.0
	if not can_use_ground_jump and _remaining_air_jumps <= 0:
		return

	var next_jump_velocity: float = jump_velocity
	if _can_use_slide_jump_bonus():
		next_jump_velocity *= slide_jump_velocity_multiplier

	_player.velocity.y = next_jump_velocity
	_jump_buffer_timer = 0.0
	_coyote_timer = 0.0
	_crouching = false
	_stop_slide()

	if not can_use_ground_jump:
		_remaining_air_jumps = maxi(_remaining_air_jumps - 1, 0)


func _apply_gravity(delta: float) -> void:
	if _player.is_on_floor() and _player.velocity.y >= 0.0:
		_player.velocity.y = 0.0
		return

	var current_gravity: float = fall_gravity if _player.velocity.y > 0.0 else gravity
	_player.velocity.y = minf(_player.velocity.y + current_gravity * delta, max_fall_speed)


func _apply_jump_cut() -> void:
	if Input.is_action_just_released("jump") and _player.velocity.y < 0.0:
		_player.velocity.y *= jump_cut_multiplier


func _get_available_air_jumps() -> int:
	return maxi(max_jumps - 1, 0)


func _get_slide_duration() -> float:
	return maxf(slide_flat_time + slide_slowdown_time, 0.0)


func _can_use_slide_jump_bonus() -> bool:
	var bonus_end_time: float = maxf(_get_slide_duration() - slide_jump_bonus_end_offset, 0.0)
	return _sliding and _slide_timer < bonus_end_time


func _can_unlock_hit_air_control_for_jump(on_floor: bool) -> bool:
	if not _hit_air_control_locked:
		return false
	if _jump_buffer_timer <= 0.0 or max_jumps <= 0:
		return false
	if _crouching and not _sliding:
		return false

	var can_use_ground_jump: bool = on_floor and _player.velocity.y < 0.0
	if can_use_ground_jump:
		return true

	return _remaining_air_jumps > 0


func _is_on_climbable_tile() -> bool:
	var climb_map: LevelTileMap = _player.get_climb_map()
	return climb_map != null and climb_map.is_climbable_at_world_position(_get_climb_probe_position())


func _get_climb_probe_position() -> Vector2:
	return _player.global_position + climb_probe_offset


func _stop_slide() -> void:
	_sliding = false
	_slide_timer = 0.0


func _clear_control_state() -> void:
	_crouching = false
	_stop_climb()
	_stop_slide()
	_coyote_timer = 0.0
	_jump_buffer_timer = 0.0
	_remaining_air_jumps = 0
	_unlock_hit_air_control()


func _unlock_hit_air_control() -> void:
	_hit_air_control_locked = false
	_hit_air_control_was_airborne = false
