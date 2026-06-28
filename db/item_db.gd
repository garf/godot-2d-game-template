class_name ItemDb

enum Keys {
	# Weapons
	MINIGUN,

	# Upgrades
	COOLING_UNIT,
}


const ITEM_RESOURCE_PATHS := {
	Keys.MINIGUN: '',
	Keys.COOLING_UNIT: '',
}


static func get_item_resource(key: Keys) -> ItemRes:
	var resource_path: String = ITEM_RESOURCE_PATHS.get(key, '')
	if resource_path.is_empty():
		push_error("Missing item resource path for key: %s" % Keys.keys()[key])
		return null

	return load(resource_path) as ItemRes


const ITEM_SCENE_PATH := {
	Keys.MINIGUN: '',
	Keys.COOLING_UNIT: '',
}


static func get_item_scene(key: Keys) -> PackedScene:
	var scene_path: String = ITEM_SCENE_PATH.get(key, '')
	if scene_path.is_empty():
		push_error("Missing item scene path for key: %s" % Keys.keys()[key])
		return null

	return load(scene_path) as PackedScene
