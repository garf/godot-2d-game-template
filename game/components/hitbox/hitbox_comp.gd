class_name HitboxComp extends Area2D


@export var damage: float = 10.0
@export var hit_cooldown: float = 0.35

var _hurtbox_cooldowns: Dictionary[HurtboxComp, float] = {}


func _ready() -> void:
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)


func _physics_process(delta: float) -> void:
	var hurtboxes: Array[HurtboxComp] = []
	hurtboxes.assign(_hurtbox_cooldowns.keys())

	for hurtbox: HurtboxComp in hurtboxes:
		if not is_instance_valid(hurtbox):
			_hurtbox_cooldowns.erase(hurtbox)
			continue

		var next_cooldown: float = maxf(_hurtbox_cooldowns[hurtbox] - delta, 0.0)
		_hurtbox_cooldowns[hurtbox] = next_cooldown

		if next_cooldown <= 0.0:
			_hit_hurtbox(hurtbox)


func _hit_hurtbox(hurtbox: HurtboxComp) -> void:
	hurtbox.receive_hit(damage, global_position, self)
	_hurtbox_cooldowns[hurtbox] = maxf(hit_cooldown, 0.0)


func _on_area_entered(area: Area2D) -> void:
	var hurtbox: HurtboxComp = area as HurtboxComp
	if hurtbox == null:
		return

	_hurtbox_cooldowns[hurtbox] = 0.0
	_hit_hurtbox(hurtbox)


func _on_area_exited(area: Area2D) -> void:
	var hurtbox: HurtboxComp = area as HurtboxComp
	if hurtbox == null:
		return

	_hurtbox_cooldowns.erase(hurtbox)
