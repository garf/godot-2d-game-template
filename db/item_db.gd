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
	return load(ITEM_RESOURCE_PATHS.get(key))


const ITEM_SCENE_PATH := {
	Keys.MINIGUN: '',
	Keys.COOLING_UNIT: '',
}


static func get_item_scene(key: Keys) -> PackedScene:
	return load(ITEM_SCENE_PATH.get(key))
