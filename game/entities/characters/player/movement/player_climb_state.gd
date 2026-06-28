class_name PlayerClimbState extends PlayerMovementState


func physics_update(delta: float) -> void:
	_apply_climb_movement(delta)
	apply_jump()
	apply_jump_cut()
	move_player()
	_stop_on_floor_contact()


func _apply_climb_movement(delta: float) -> void:
	var climb_map: LevelTileMap = controller._player.get_climb_map()
	if climb_map == null:
		controller._stop_climb()
		return

	var probe_position: Vector2 = controller._get_climb_probe_position()
	var climb_tile_center: Vector2 = climb_map.get_climb_tile_center_at_world_position(probe_position)
	var climb_velocity: float = controller.climb_axis * controller.config.climb_speed
	if controller.climb_axis < 0.0 and not climb_map.is_climbable_at_world_position(
		probe_position + Vector2(0.0, climb_velocity * delta)
	):
		climb_velocity = 0.0

	controller._player.global_position.x = climb_tile_center.x
	controller._player.velocity.x = 0.0
	controller._player.velocity.y = climb_velocity
	controller._climb_moving = not is_zero_approx(climb_velocity)


func _stop_on_floor_contact() -> void:
	if controller._player.is_on_floor() and controller.climb_axis >= 0.0:
		controller._stop_climb()
