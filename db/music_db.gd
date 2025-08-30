class_name MusicDb


enum Keys {
	DAISY_DANCE,
}

static var ALL_KEYS: Array[Keys] = [
	Keys.DAISY_DANCE,
]


const MUSIC_RESOURCE_PATHS := {
	Keys.DAISY_DANCE: 'res://assets/audio/music/daisy_dance.mp3',
}


static func get_music_stream(key: Keys) -> AudioStream:
	return load(MUSIC_RESOURCE_PATHS.get(key))
