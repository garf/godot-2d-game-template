extends Node

@onready var sound_players = get_children()

var sounds = {
	#"player_died": load('res://assets/audio/music/Game_Over_2.wav'),
}

const DEFAULT_VOLUME: float = 1.0


func play(sound_name: String, volume: float = DEFAULT_VOLUME):
	var sound_to_play = sounds[sound_name]
	play_file(sound_to_play, volume)


func play_file_vari(audio: AudioStream):
	self.play_file(audio, randf_range(0.6, 1.0), randf_range(0.6, 1.4))

func play_file(audio: AudioStream, volume: float = DEFAULT_VOLUME, pitch: float = 1.0):
	var volume_db = linear_to_db(volume)

	for sound_player: AudioStreamPlayer in sound_players:
		if !sound_player.playing:
			sound_player.stream = audio
			sound_player.volume_db = volume_db
			sound_player.pitch_scale = pitch
			sound_player.play()
			return

	# If no available sound players, add an extra one or notify
	var extra_player = AudioStreamPlayer.new()
	add_child(extra_player)
	sound_players.append(extra_player)

	extra_player.stream = audio
	extra_player.volume_db = volume_db
	extra_player.play()


func play_random_file(audio_streams: Array, volume: float = DEFAULT_VOLUME):
	if audio_streams.size() == 0:
		push_error("No audio streams provided for random selection.")
		return

	play_file(audio_streams.pick_random(), volume)
