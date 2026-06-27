class_name HudUi extends CanvasLayer

@onready var money_value_label: Label = %MoneyValueLabel


func _enter_tree() -> void:
	Events.WALLET_money_changed.connect(_on_money_changed)
	Events.VIEW_view_loaded.connect(_on_view_loaded)


func _exit_tree() -> void:
	if Events.WALLET_money_changed.is_connected(_on_money_changed):
		Events.WALLET_money_changed.disconnect(_on_money_changed)
	if Events.VIEW_view_loaded.is_connected(_on_view_loaded):
		Events.VIEW_view_loaded.disconnect(_on_view_loaded)


func _on_view_loaded(view: ViewDb.Keys) -> void:
	if view != ViewDb.Keys.GAME:
		return

	Events.WALLET_sync_requested.emit()


func _on_money_changed(amount: int, old_amount: int) -> void:
	var tween = create_tween().set_trans(Tween.TRANS_EXPO)
	tween.tween_method(_render_money, old_amount, amount, 1.5)


## Method for a tween, to produce an amount change animation
func _render_money(amount: int) -> void:
	money_value_label.text = str(amount)
