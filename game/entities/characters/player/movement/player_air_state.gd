class_name PlayerAirState extends PlayerMovementState


func physics_update(delta: float) -> void:
	clear_ground_control()
	apply_horizontal_movement(controller.input_axis, delta, false)
	apply_jump()
	apply_gravity(delta)
	apply_jump_cut()
	move_player()
