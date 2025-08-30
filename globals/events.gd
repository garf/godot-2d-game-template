extends Node

@warning_ignore_start('unused_signal')

signal VIEW_load_view(view: ViewDb.Keys)
signal VIEW_show_loading_view(percentage: float)
signal VIEW_show_loading_text(text: String)
signal VIEW_hide_loading_view

signal PLAYER_knockback(direction: Vector2, intencity: float)

@warning_ignore_restore('unused_signal')
