extends Node

@warning_ignore_start('unused_signal')

signal VIEW_load_view(view: ViewDb.Keys)
signal VIEW_show_loading_view(percentage: float)
signal VIEW_show_loading_text(text: String)
signal VIEW_hide_loading_view

signal WALLET_money_spend_requested(amount: int, callback: Callable)
signal WALLET_sync_requested
signal WALLET_money_changed(amount: int, old_amount: int)

@warning_ignore_restore('unused_signal')
