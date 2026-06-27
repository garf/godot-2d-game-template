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

var _crouching: bool = false
var _sliding: bool = false
var _slide_timer: float = 0.0
var _coyote_timer: float = 0.0
var _jump_buffer_timer: float = 0.0
var _remaining_air_jumps: int = 0
var _was_on_floor: bool = false
var _air_control_lock_timer: float = 0.0

@onready var _player: Player = get_parent() as Player


func physics_update(delta: float) -> void:
	if _player.is_dead():
		_clear_control_state()
		_apply_dead_movement(delta)
		_was_on_floor = _player.is_on_floor()
		return

	var input_axis: float = Input.get_axis("walk_left", "walk_right")
	var is_air_control_locked: bool = _air_control_lock_timer > 0.0
	if _air_control_lock_timer > 0.0:
		_air_control_lock_timer = maxf(_air_control_lock_timer - delta, 0.0)

	var on_floor: bool = _player.is_on_floor()
	var just_landed: bool = on_floor and not _was_on_floor

	_update_timers(delta, on_floor)
	if not is_air_control_locked:
		_update_facing(input_axis)
	_update_crouch(delta, on_floor, just_landed)
	if not is_air_control_locked:
		_apply_horizontal_movement(input_axis, delta, on_floor)
	_apply_jump()
	_apply_gravity(delta)
	_apply_jump_cut()

	_player.move_and_slide()
	_was_on_floor = on_floor


func is_crouching() -> bool:
	return _crouching


func start_hit_reaction(launch_velocity: Vector2, air_control_lock_time: float) -> void:
	_clear_control_state()
	_player.velocity = launch_velocity
	_air_control_lock_timer = maxf(air_control_lock_time, 0.0)


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


func _apply_jump() -> void:
	if _jump_buffer_timer <= 0.0 or max_jumps <= 0:
		return
	if _crouching and not _sliding:
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


func _stop_slide() -> void:
	_sliding = false
	_slide_timer = 0.0


func _clear_control_state() -> void:
	_crouching = false
	_stop_slide()
	_coyote_timer = 0.0
	_jump_buffer_timer = 0.0
	_remaining_air_jumps = 0
	_air_control_lock_timer = 0.0
