class_name HpComp extends Node

signal hp_depleted
signal hp_changed(current_hp: float, old_hp: float)

@export var max_hp: float = 4.0: set = set_max_hp
@export var hp: float = 4.0: set = set_hp


func deal_damage(amount: float) -> float:
	set_hp(hp - amount)
	return hp


func heal(amount: float) -> float:
	set_hp(hp + amount)
	return hp


func heal_full() -> float:
	set_hp(max_hp)
	return hp


func set_max_hp(amount: float) -> void:
	var old_value: float = hp
	max_hp = maxf(amount, 0.0)
	hp = clampf(hp, 0.0, max_hp)
	hp_changed.emit(hp, old_value)
	if old_value > 0.0 and hp <= 0.0:
		hp_depleted.emit()


func set_hp(amount: float) -> void:
	var old_value: float = hp
	hp = clampf(amount, 0.0, max_hp)
	hp_changed.emit(hp, old_value)
	if old_value > 0.0 and hp <= 0.0:
		hp_depleted.emit()


## Returns 1.0 if health is 100%
func get_hp_percentage() -> float:
	if max_hp <= 0:
		return 0.0

	return float(hp) / float(max_hp)
