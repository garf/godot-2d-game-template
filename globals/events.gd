extends Node

@warning_ignore_start('unused_signal')

signal VIEW_load_view(view: ViewDb.Keys)
signal VIEW_view_loaded(view: ViewDb.Keys)
signal VIEW_show_loading_view(percentage: float)
signal VIEW_show_loading_text(text: String)
signal VIEW_hide_loading_view

signal WALLET_money_spend_requested(amount: int, callback: Callable)
signal WALLET_sync_requested
signal WALLET_money_changed(amount: int, old_amount: int)

signal PLAYER_hp_changed(current_hp: float, max_hp: float, old_hp: float)
signal PLAYER_death_requested
signal PLAYER_died
signal PLAYER_respawn_requested(spawn_global_position: Vector2)
signal PLAYER_respawned(spawn_global_position: Vector2)

@warning_ignore_restore('unused_signal')
