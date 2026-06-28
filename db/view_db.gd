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
	var scene_path: String = get_view_scene_path(key)
	if scene_path.is_empty():
		return null

	return load(scene_path) as PackedScene


static func get_view_scene_path(key: Keys) -> String:
	var scene_path: String = VIEW_SCENE_PATHS.get(key, '')
	if scene_path.is_empty():
		push_error("Missing view scene path for key: %s" % Keys.keys()[key])

	return scene_path
