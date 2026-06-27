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
@export var crouch_speed_multiplier: float = 0.45

var _crouching: bool = false
var _coyote_timer: float = 0.0
var _jump_buffer_timer: float = 0.0

@onready var _player: Player = get_parent() as Player


func physics_update(delta: float) -> void:
	var input_axis: float = Input.get_axis("walk_left", "walk_right")
	var on_floor: bool = _player.is_on_floor()

	_update_timers(delta, on_floor)
	_update_facing(input_axis)
	_update_crouch(on_floor)
	_apply_horizontal_movement(input_axis, delta, on_floor)
	_apply_jump()
	_apply_gravity(delta)
	_apply_jump_cut()

	_player.move_and_slide()


func is_crouching() -> bool:
	return _crouching


func _update_timers(delta: float, on_floor: bool) -> void:
	if on_floor:
		_coyote_timer = coyote_time
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


func _update_crouch(on_floor: bool) -> void:
	_crouching = on_floor and Input.is_action_pressed("crouch")


func _apply_horizontal_movement(input_axis: float, delta: float, on_floor: bool) -> void:
	var speed_multiplier: float = crouch_speed_multiplier if _crouching else 1.0
	var target_speed: float = input_axis * max_walk_speed * speed_multiplier
	var acceleration: float = _get_horizontal_acceleration(input_axis, target_speed, on_floor)

	_player.velocity.x = move_toward(_player.velocity.x, target_speed, acceleration * delta)


func _get_horizontal_acceleration(input_axis: float, target_speed: float, on_floor: bool) -> float:
	if is_zero_approx(input_axis):
		return ground_deceleration if on_floor else air_deceleration

	var is_turning: bool = not is_zero_approx(_player.velocity.x) and signf(_player.velocity.x) != signf(target_speed)
	if is_turning:
		return turn_acceleration

	return ground_acceleration if on_floor else air_acceleration


func _apply_jump() -> void:
	if _jump_buffer_timer <= 0.0 or _coyote_timer <= 0.0 or _crouching:
		return

	_player.velocity.y = jump_velocity
	_jump_buffer_timer = 0.0
	_coyote_timer = 0.0
	_crouching = false


func _apply_gravity(delta: float) -> void:
	if _player.is_on_floor() and _player.velocity.y >= 0.0:
		_player.velocity.y = 0.0
		return

	var current_gravity: float = fall_gravity if _player.velocity.y > 0.0 else gravity
	_player.velocity.y = minf(_player.velocity.y + current_gravity * delta, max_fall_speed)


func _apply_jump_cut() -> void:
	if Input.is_action_just_released("jump") and _player.velocity.y < 0.0:
		_player.velocity.y *= jump_cut_multiplier
