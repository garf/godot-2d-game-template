class_name HurtboxComp extends Area2D


signal hit_received(damage: float, source_position: Vector2, hitbox: HitboxComp)

@export var damage_receiver_path: NodePath = ^".."

var _damage_receiver: Node


func _ready() -> void:
	_damage_receiver = _find_damage_receiver()


func receive_hit(damage: float, source_position: Vector2, hitbox: HitboxComp) -> void:
	hit_received.emit(damage, source_position, hitbox)
	if _damage_receiver == null or not _damage_receiver.has_method("receive_hit"):
		return

	_damage_receiver.call("receive_hit", damage, source_position, hitbox)


func _find_damage_receiver() -> Node:
	var damage_receiver: Node = get_node_or_null(damage_receiver_path)
	if damage_receiver != null:
		return damage_receiver

	return get_parent()
