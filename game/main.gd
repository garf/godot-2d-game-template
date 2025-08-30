class_name Main extends Node


func _ready() -> void:
	load_game_view()


func load_game_view() -> void:
	Events.VIEW_load_view.emit(ViewDb.Keys.GAME)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed(&'ui_cancel'):
		get_tree().quit()
