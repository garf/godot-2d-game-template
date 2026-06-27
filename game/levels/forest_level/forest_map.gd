class_name ForestMap extends TileMapLayer

@onready var _kill_zone: Area2D = %KillZone


func _ready() -> void:
	_kill_zone.body_entered.connect(_on_kill_zone_body_entered)


func _on_kill_zone_body_entered(body: Node2D) -> void:
	if body is Player:
		Events.PLAYER_death_requested.emit()
