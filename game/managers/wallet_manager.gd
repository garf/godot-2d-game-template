extends Node

var money: int = 1000 : set = _set_money


func _enter_tree() -> void:
	Events.WALLET_money_spend_requested.connect(_on_money_spend_requested)
	Events.WALLET_sync_requested.connect(_on_sync_requested)


func _exit_tree() -> void:
	if Events.WALLET_money_spend_requested.is_connected(_on_money_spend_requested):
		Events.WALLET_money_spend_requested.disconnect(_on_money_spend_requested)
	if Events.WALLET_sync_requested.is_connected(_on_sync_requested):
		Events.WALLET_sync_requested.disconnect(_on_sync_requested)


func _on_money_spend_requested(amount: int, callback: Callable) -> void:
	if money < amount:
		callback.call(false)
		return

	money = money - amount
	callback.call(true)


func _on_sync_requested() -> void:
	Events.WALLET_money_changed.emit(money, 0)


func _set_money(amount: int) -> void:
	var old_amount: int = money
	money = amount
	Events.WALLET_money_changed.emit(money, old_amount)
