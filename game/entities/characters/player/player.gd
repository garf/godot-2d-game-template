class_name Player extends CharacterBody2D


signal facing_direction_changed(facing_direction: Vector2)

var facing_sign: int = 1
var facing_direction: Vector2 = Vector2.RIGHT

@onready var _sprite: AnimatedSprite2D = $PlayerSprites
@onready var _movement_controller: PlayerMovementController = $MovementController


func _ready() -> void:
	_sync_facing_visuals()
	_sprite.play(&"idle_right")


func _physics_process(delta: float) -> void:
	_movement_controller.physics_update(delta)
	_update_animation()


func set_facing_sign(value: int) -> void:
	var next_facing_sign: int = 1
	if value < 0:
		next_facing_sign = -1
	elif value == 0:
		return

	if facing_sign == next_facing_sign:
		return

	facing_sign = next_facing_sign
	facing_direction = Vector2(float(facing_sign), 0.0)
	_sync_facing_visuals()
	facing_direction_changed.emit(facing_direction)


func get_facing_direction() -> Vector2:
	return facing_direction


func _sync_facing_visuals() -> void:
	_sprite.flip_h = facing_sign < 0


func _update_animation() -> void:
	var next_animation: StringName = &"idle_right"

	if not is_on_floor():
		next_animation = &"jump_right"
	elif _movement_controller.is_crouching():
		next_animation = &"crouch_right"
	elif absf(velocity.x) > 5.0:
		next_animation = &"walk_right"

	_play_animation(next_animation)


func _play_animation(animation: StringName) -> void:
	if _sprite.animation == animation:
		return

	_sprite.play(animation)
