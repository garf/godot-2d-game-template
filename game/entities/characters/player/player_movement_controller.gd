class_name PlayerMovementController extends Node

@export var config: PlayerMovementConfig = PlayerMovementConfig.new()

var input_axis: float = 0.0
var climb_axis: float = 0.0
var on_floor: bool = false
var just_landed: bool = false

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
var _state: PlayerMovementState = null

@onready var _player: Player = get_parent() as Player
@onready var _ground_state: PlayerGroundState = $GroundState
@onready var _air_state: PlayerAirState = $AirState
@onready var _climb_state: PlayerClimbState = $ClimbState
@onready var _hit_stun_state: PlayerHitStunState = $HitStunState
@onready var _dead_state: PlayerDeadState = $DeadState


func _ready() -> void:
	for child: Node in get_children():
		var movement_state: PlayerMovementState = child as PlayerMovementState
		if movement_state != null:
			movement_state.setup(self)


func physics_update(delta: float) -> void:
	if _player.is_dead():
		_change_state(_dead_state)
		_state.physics_update(delta)
		_was_on_floor = _player.is_on_floor()
		return

	_update_frame_context()
	_update_hit_air_control_lock()
	_update_timers(delta)
	if _can_unlock_hit_air_control_for_jump():
		_unlock_hit_air_control()

	if not _hit_air_control_locked:
		_update_facing()
		_update_climb_state()
		if _climbing and not is_zero_approx(input_axis):
			_detach_from_climb()

	_change_state(_get_next_alive_state())
	_state.physics_update(delta)
	_was_on_floor = on_floor


func is_crouching() -> bool:
	return _crouching


func is_climbing() -> bool:
	return _climbing


func is_climbing_moving() -> bool:
	return _climb_moving


func start_hit_reaction(launch_direction_sign: float) -> void:
	clear_control_state()
	var launch_strength: float = maxf(config.hit_launch_strength, 0.0)
	_player.velocity = Vector2(launch_strength * launch_direction_sign, -launch_strength)
	_remaining_air_jumps = _get_available_air_jumps()
	_hit_air_control_locked = true
	_hit_air_control_was_airborne = false
	_change_state(_hit_stun_state)


func clear_control_state() -> void:
	_crouching = false
	_stop_climb()
	_stop_slide()
	_coyote_timer = 0.0
	_jump_buffer_timer = 0.0
	_remaining_air_jumps = 0
	_unlock_hit_air_control()


func _change_state(next_state: PlayerMovementState) -> void:
	if _state == next_state:
		return

	var previous_state: PlayerMovementState = _state
	if _state != null:
		_state.exit(next_state)

	_state = next_state
	_state.enter(previous_state)


func _get_next_alive_state() -> PlayerMovementState:
	if _hit_air_control_locked:
		return _hit_stun_state
	if _climbing:
		return _climb_state
	if on_floor:
		return _ground_state

	return _air_state


func _update_frame_context() -> void:
	on_floor = _player.is_on_floor()
	just_landed = on_floor and not _was_on_floor
	input_axis = Input.get_axis("walk_left", "walk_right")
	climb_axis = Input.get_axis("move_up", "move_down")


func _update_hit_air_control_lock() -> void:
	if _hit_air_control_locked and not on_floor:
		_hit_air_control_was_airborne = true
	elif _hit_air_control_locked and _hit_air_control_was_airborne and on_floor:
		_unlock_hit_air_control()


func _update_timers(delta: float) -> void:
	if on_floor:
		_coyote_timer = config.coyote_time
		_remaining_air_jumps = _get_available_air_jumps()
	else:
		_coyote_timer = maxf(_coyote_timer - delta, 0.0)

	if Input.is_action_just_pressed("jump"):
		_jump_buffer_timer = config.jump_buffer_time
	else:
		_jump_buffer_timer = maxf(_jump_buffer_timer - delta, 0.0)


func _update_facing() -> void:
	if input_axis > 0.0:
		_player.set_facing_sign(1)
	elif input_axis < 0.0:
		_player.set_facing_sign(-1)


func _update_climb_state() -> void:
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


func _detach_from_climb() -> void:
	_stop_climb()
	_coyote_timer = config.coyote_time
	_remaining_air_jumps = _get_available_air_jumps()
	_player.velocity.x = input_axis * config.climb_detach_horizontal_speed
	_player.velocity.y = 0.0


func _get_available_air_jumps() -> int:
	return maxi(config.max_jumps - 1, 0)


func _can_unlock_hit_air_control_for_jump() -> bool:
	if not _hit_air_control_locked:
		return false
	if _jump_buffer_timer <= 0.0 or config.max_jumps <= 0:
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
	return _player.global_position + config.climb_probe_offset


func _stop_slide() -> void:
	_sliding = false
	_slide_timer = 0.0


func _unlock_hit_air_control() -> void:
	_hit_air_control_locked = false
	_hit_air_control_was_airborne = false
