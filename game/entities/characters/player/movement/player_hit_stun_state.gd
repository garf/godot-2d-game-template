class_name PlayerHitStunState extends PlayerMovementState


func physics_update(delta: float) -> void:
	apply_jump()
	apply_gravity(delta)
	apply_jump_cut()
	move_player()
