extends Node

const DEFAULT_VOLUME: float = 1.0
const MIN_DB_VOLUME: float = -60.0

@onready var sound_players: Array[AudioStreamPlayer] = _get_sound_players()

var sounds: Dictionary[String, AudioStream] = {
	#"player_died": load('res://assets/audio/music/Game_Over_2.wav'),
}


func play(sound_name: String, volume: float = DEFAULT_VOLUME) -> void:
	if not sounds.has(sound_name):
		push_error("Unknown sound: %s" % sound_name)
		return

	var sound_to_play: AudioStream = sounds[sound_name]
	play_file(sound_to_play, volume)


func play_file_vari(audio: AudioStream) -> void:
	play_file(audio, randf_range(0.6, 1.0), randf_range(0.6, 1.4))


func play_file(audio: AudioStream, volume: float = DEFAULT_VOLUME, pitch: float = 1.0) -> void:
	if audio == null:
		return

	var clamped_volume: float = clampf(volume, 0.0, 1.0)
	var volume_db: float = linear_to_db(clamped_volume) if clamped_volume > 0.0 else MIN_DB_VOLUME

	for sound_player: AudioStreamPlayer in sound_players:
		if not sound_player.playing:
			_play_on_player(sound_player, audio, volume_db, pitch)
			return

	var extra_player: AudioStreamPlayer = AudioStreamPlayer.new()
	add_child(extra_player)
	sound_players.append(extra_player)
	_play_on_player(extra_player, audio, volume_db, pitch)


func play_random_file(audio_streams: Array[AudioStream], volume: float = DEFAULT_VOLUME) -> void:
	if audio_streams.is_empty():
		push_error("No audio streams provided for random selection.")
		return

	play_file(audio_streams.pick_random(), volume)


func _play_on_player(sound_player: AudioStreamPlayer, audio: AudioStream, volume_db: float, pitch: float) -> void:
	sound_player.stream = audio
	sound_player.volume_db = volume_db
	sound_player.pitch_scale = pitch
	sound_player.play()


func _get_sound_players() -> Array[AudioStreamPlayer]:
	var players: Array[AudioStreamPlayer] = []
	for child: Node in get_children():
		var sound_player: AudioStreamPlayer = child as AudioStreamPlayer
		if sound_player != null:
			players.append(sound_player)

	return players
