class_name PlayerMovementConfig extends Resource

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
@export var floor_snap_length: float = 4.0
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
