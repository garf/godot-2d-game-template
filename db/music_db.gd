class_name MusicDb


enum Keys {
	DUSK_MATTER,
}

static var ALL_KEYS: Array[Keys] = [
	Keys.DUSK_MATTER,
]


const MUSIC_RESOURCE_PATHS := {
	Keys.DUSK_MATTER: 'res://assets/audio/music/dusk_matter.mp3',
}


static func get_music_stream(key: Keys) -> AudioStream:
	return load(MUSIC_RESOURCE_PATHS.get(key))
