class_name _TemplateDb

enum Keys {
	EXAMPLE,
}


const ITEM_RESOURCE_PATHS := {
	Keys.EXAMPLE: '',

}

static func get_item_resource(key: Keys) -> EntityRes:
	return load(ITEM_RESOURCE_PATHS.get(key))


const ITEM_SCENE_PATH := {
	Keys.EXAMPLE: '',
}


static func get_item_scene(key: Keys) -> PackedScene:
	return load(ITEM_SCENE_PATH.get(key))
