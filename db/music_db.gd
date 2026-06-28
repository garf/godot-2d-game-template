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
	var stream_path: String = MUSIC_RESOURCE_PATHS.get(key, '')
	if stream_path.is_empty():
		push_error("Missing music stream path for key: %s" % Keys.keys()[key])
		return null

	return load(stream_path) as AudioStream
