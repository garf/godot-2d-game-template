class_name HpComp extends Node

signal hp_depleted
signal hp_changed

@export var max_hp: float = 4.0: set = set_max_hp
@export var hp: float = 4.0: set = set_hp


func deal_damage(amount: float) -> float:
	var old_value = hp
	hp -= amount
	hp_changed.emit(hp, old_value)
	if hp <= 0.0:
		hp_depleted.emit()

	return hp


func heal(amount: float) -> float:
	var old_value = hp
	hp += amount
	hp = min(hp, max_hp)
	hp_changed.emit(hp, old_value)
	return hp


func heal_full() -> float:
	var old_value = hp
	hp = max_hp
	hp_changed.emit(hp, old_value)
	return hp


func set_max_hp(amount: float) -> void:
	var old_value = hp
	max_hp = amount
	hp = min(hp, amount)
	hp_changed.emit(hp, old_value)


func set_hp(amount: float) -> void:
	var old_value = hp
	hp = min(max_hp, amount)
	hp_changed.emit(hp, old_value)
	if hp <= 0.0:
		hp_depleted.emit()


## Returns 1.0 if health is 100%
func get_hp_percentage() -> float:
	if max_hp <= 0:
		return 0.0

	return float(hp) / float(max_hp)
