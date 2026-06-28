class_name PlayerGroundState extends PlayerMovementState


func physics_update(delta: float) -> void:
	_update_crouch(delta)
	apply_horizontal_movement(controller.input_axis, delta, true)
	apply_jump()
	apply_gravity(delta)
	apply_jump_cut()
	move_player()


func _update_crouch(delta: float) -> void:
	if not controller.on_floor or not Input.is_action_pressed("crouch"):
		clear_ground_control()
		return

	controller._crouching = true
	var can_start_slide: bool = Input.is_action_just_pressed("crouch") or controller.just_landed
	if can_start_slide and absf(controller._player.velocity.x) >= controller.config.slide_min_start_speed:
		controller._sliding = true
		controller._slide_timer = 0.0
	elif controller._sliding:
		controller._slide_timer += delta
		if controller._slide_timer >= _get_slide_duration():
			controller._stop_slide()
