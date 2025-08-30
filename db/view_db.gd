class_name ViewDb extends Node

enum Keys {
	LOADING,
	GAME,
}

const VIEW_SCENE_PATHS := {
	Keys.LOADING: 'res://game/views/loading_view/loading_view.tscn',
	Keys.GAME: 'res://game/views/game_view/game_view.tscn',
}


static func get_view_scene(key: Keys) -> PackedScene:
	return load(VIEW_SCENE_PATHS.get(key))


static func get_view_scene_path(key: Keys) -> String:
	return VIEW_SCENE_PATHS.get(key)
