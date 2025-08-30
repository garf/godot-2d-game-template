class_name Turret extends Node2D

@onready var hp_comp: HpComp = %HpComp


func _ready() -> void:
	hp_comp.hp_depleted.connect(die)


func die() -> void:
	print('Turret is dead!')
	queue_free()
