class_name PlayerMovementState extends Node

var controller: PlayerMovementController = null


func setup(movement_controller: PlayerMovementController) -> void:
	controller = movement_controller


func enter(_previous_state: PlayerMovementState) -> void:
	pass


func exit(_next_state: PlayerMovementState) -> void:
	pass


func physics_update(_delta: float) -> void:
	pass


func clear_ground_control() -> void:
	controller._crouching = false
	controller._stop_slide()


func apply_horizontal_movement(horizontal_axis: float, delta: float, floor_contact: bool) -> void:
	var speed_multiplier: float = _get_speed_multiplier()
	var target_speed: float = horizontal_axis * controller.config.max_walk_speed * speed_multiplier
	var acceleration: float = _get_horizontal_acceleration(horizontal_axis, target_speed, floor_contact)

	controller._player.velocity.x = move_toward(controller._player.velocity.x, target_speed, acceleration * delta)


func apply_jump() -> void:
	if controller._jump_buffer_timer <= 0.0 or controller.config.max_jumps <= 0:
		return
	if controller._crouching and not controller._sliding:
		return

	if controller._climbing:
		controller._player.velocity.y = controller.config.jump_velocity
		controller._jump_buffer_timer = 0.0
		controller._coyote_timer = 0.0
		controller._remaining_air_jumps = controller._get_available_air_jumps()
		controller._stop_climb()
		return

	var can_use_ground_jump: bool = controller._coyote_timer > 0.0
	if not can_use_ground_jump and controller._remaining_air_jumps <= 0:
		return

	var next_jump_velocity: float = controller.config.jump_velocity
	if _can_use_slide_jump_bonus():
		next_jump_velocity *= controller.config.slide_jump_velocity_multiplier

	controller._player.velocity.y = next_jump_velocity
	controller._jump_buffer_timer = 0.0
	controller._coyote_timer = 0.0
	controller._crouching = false
	controller._stop_slide()

	if not can_use_ground_jump:
		controller._remaining_air_jumps = maxi(controller._remaining_air_jumps - 1, 0)


func apply_gravity(delta: float) -> void:
	if controller._player.is_on_floor() and controller._player.velocity.y >= 0.0:
		controller._player.velocity.y = 0.0
		return

	var current_gravity: float = controller.config.fall_gravity if controller._player.velocity.y > 0.0 else controller.config.gravity
	controller._player.velocity.y = minf(
		controller._player.velocity.y + current_gravity * delta,
		controller.config.max_fall_speed
	)


func apply_jump_cut() -> void:
	if Input.is_action_just_released("jump") and controller._player.velocity.y < 0.0:
		controller._player.velocity.y *= controller.config.jump_cut_multiplier


func move_player() -> void:
	controller._player.move_and_slide()


func _get_speed_multiplier() -> float:
	if controller._sliding:
		return _get_slide_speed_multiplier()
	if controller._crouching:
		return controller.config.crouch_speed_multiplier

	return 1.0


func _get_slide_speed_multiplier() -> float:
	if controller._slide_timer <= controller.config.slide_flat_time:
		return controller.config.slide_speed_multiplier
	if controller.config.slide_slowdown_time <= 0.0:
		return controller.config.crouch_speed_multiplier

	var slowdown_elapsed: float = controller._slide_timer - controller.config.slide_flat_time
	var slowdown_progress: float = clampf(slowdown_elapsed / controller.config.slide_slowdown_time, 0.0, 1.0)
	return lerpf(controller.config.slide_speed_multiplier, controller.config.crouch_speed_multiplier, slowdown_progress)


func _get_horizontal_acceleration(horizontal_axis: float, target_speed: float, floor_contact: bool) -> float:
	if is_zero_approx(horizontal_axis):
		return controller.config.ground_deceleration if floor_contact else controller.config.air_deceleration

	var is_turning: bool = (
		not is_zero_approx(controller._player.velocity.x)
		and signf(controller._player.velocity.x) != signf(target_speed)
	)
	if is_turning:
		return controller.config.turn_acceleration

	return controller.config.ground_acceleration if floor_contact else controller.config.air_acceleration


func _get_slide_duration() -> float:
	return maxf(controller.config.slide_flat_time + controller.config.slide_slowdown_time, 0.0)


func _can_use_slide_jump_bonus() -> bool:
	var bonus_end_time: float = maxf(_get_slide_duration() - controller.config.slide_jump_bonus_end_offset, 0.0)
	return controller._sliding and controller._slide_timer < bonus_end_time
