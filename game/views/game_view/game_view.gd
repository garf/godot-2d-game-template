class_name GameView extends Node2D

func _ready() -> void:
	MusicPlayer.play_file(MusicDb.Keys.DAISY_DANCE, true)
