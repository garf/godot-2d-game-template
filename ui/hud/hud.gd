class_name HudUi extends CanvasLayer

@onready var money_value_label: Label = %MoneyValueLabel


func _enter_tree() -> void:
	Events.WALLET_money_changed.connect(_on_money_changed)

func _ready() -> void:
	Events.WALLET_sync_requested.emit()


func _on_money_changed(amount: int, old_amount: int) -> void:
	var tween = create_tween().set_trans(Tween.TRANS_EXPO)
	tween.tween_method(_render_money, old_amount, amount, 1.5)


## Method for a tween, to produce an amount change animation
func _render_money(amount: int) -> void:
	money_value_label.text = str(amount)
