extends Node

@onready var music_player_1: AudioStreamPlayer = %MusicPlayer1
@onready var music_player_2: AudioStreamPlayer = %MusicPlayer2

const CROSSFADE_DURATION: float = 3.0
const FADE_OUT_DURATION: float = 2.0
const MIN_DB_VOLUME: float = -60.0  # Effectively silent without causing NaN issues

var default_volume: float = 1.0 : set = set_default_volume

var _current_player: AudioStreamPlayer
var _next_player: AudioStreamPlayer
var _playlist: Array[MusicDb.Keys] = []
var _playlist_index: int = 0
var _is_repeating_single: bool = false
var _is_crossfading: bool = false

func _ready() -> void:
	_current_player = music_player_1
	_next_player = music_player_2

	_current_player.volume_db = linear_to_db(default_volume)
	_next_player.volume_db = linear_to_db(0.0)

	music_player_1.finished.connect(_on_music_finished)
	music_player_2.finished.connect(_on_music_finished)


func play_file(music_key: MusicDb.Keys, repeat: bool = false) -> void:
	play_playlist([music_key], repeat)


func play_playlist(music_keys: Array[MusicDb.Keys], repeat: bool = false) -> void:
	if music_keys.is_empty():
		return

	_playlist = music_keys
	_playlist_index = 0
	_is_repeating_single = repeat and music_keys.size() == 1

	var stream = MusicDb.get_music_stream(_playlist[_playlist_index])

	_crossfade_to_stream(stream, default_volume)


func set_default_volume(volume: float) -> void:
	default_volume = clamp(volume, 0.0, 1.0)

	if _current_player.stream and _current_player.playing:
		var tween = create_tween()
		tween.tween_property(_current_player, "volume_db", linear_to_db(default_volume), 0.5)


func _crossfade_to_stream(stream: AudioStream, volume: float) -> void:
	if _is_crossfading:
		return
	_is_crossfading = true

	# Swap players
	var temp = _current_player
	_current_player = _next_player
	_next_player = temp

	_current_player.stream = stream
	_current_player.volume_db = MIN_DB_VOLUME  # Start muted safely
	_current_player.play()

	var tween = create_tween()

	# Fade in the new track
	var target_db = linear_to_db(clamp(volume, 0.0001, 1.0))
	tween.tween_property(_current_player, "volume_db", target_db, CROSSFADE_DURATION)

	# Fade out the old track safely
	if _next_player.playing and _next_player.stream:
		tween.parallel().tween_property(_next_player, "volume_db", MIN_DB_VOLUME, CROSSFADE_DURATION)
	else:
		_next_player.volume_db = MIN_DB_VOLUME

	tween.tween_callback(func():
		if _next_player.playing:
			_next_player.stop()
		_is_crossfading = false
	)


func _on_music_finished() -> void:
	if _is_repeating_single:
		_current_player.play()
		return

	_playlist_index += 1
	if _playlist_index >= _playlist.size():
		_playlist_index = 0

	var next_stream = MusicDb.get_music_stream(_playlist[_playlist_index])
	_crossfade_to_stream(next_stream, default_volume)
