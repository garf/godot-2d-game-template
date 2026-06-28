class_name PlayerDeadState extends PlayerMovementState


func enter(_previous_state: PlayerMovementState) -> void:
	controller.clear_control_state()


func physics_update(delta: float) -> void:
	_apply_dead_movement(delta)


func _apply_dead_movement(delta: float) -> void:
	if controller._player.is_on_floor() and controller._player.velocity.y >= 0.0:
		controller._player.velocity = Vector2.ZERO
		return

	apply_gravity(delta)
	move_player()

	if controller._player.is_on_floor():
		controller._player.velocity = Vector2.ZERO
