class_name HudUi extends CanvasLayer

@onready var money_value_label: Label = %MoneyValueLabel
@onready var _hp_progress_bar: ProgressBar = %HpProgressBar
@onready var _dead_screen: MarginContainer = %DeadScreen

var _money_tween: Tween = null


func _enter_tree() -> void:
	Events.WALLET_money_changed.connect(_on_money_changed)
	Events.VIEW_view_loaded.connect(_on_view_loaded)
	Events.PLAYER_hp_changed.connect(_on_player_hp_changed)
	Events.PLAYER_died.connect(_on_player_died)
	Events.PLAYER_respawned.connect(_on_player_respawned)


func _ready() -> void:
	_dead_screen.visible = false


func _exit_tree() -> void:
	if Events.WALLET_money_changed.is_connected(_on_money_changed):
		Events.WALLET_money_changed.disconnect(_on_money_changed)
	if Events.VIEW_view_loaded.is_connected(_on_view_loaded):
		Events.VIEW_view_loaded.disconnect(_on_view_loaded)
	if Events.PLAYER_hp_changed.is_connected(_on_player_hp_changed):
		Events.PLAYER_hp_changed.disconnect(_on_player_hp_changed)
	if Events.PLAYER_died.is_connected(_on_player_died):
		Events.PLAYER_died.disconnect(_on_player_died)
	if Events.PLAYER_respawned.is_connected(_on_player_respawned):
		Events.PLAYER_respawned.disconnect(_on_player_respawned)


func _on_view_loaded(view: ViewDb.Keys) -> void:
	if view != ViewDb.Keys.GAME:
		return

	Events.WALLET_sync_requested.emit()


func _on_money_changed(amount: int, old_amount: int) -> void:
	if _money_tween != null and _money_tween.is_valid():
		_money_tween.kill()

	_money_tween = create_tween().set_trans(Tween.TRANS_EXPO)
	_money_tween.tween_method(_render_money, old_amount, amount, 1.5)
	_money_tween.finished.connect(_clear_money_tween)


## Method for a tween, to produce an amount change animation
func _render_money(amount: int) -> void:
	money_value_label.text = str(amount)


func _clear_money_tween() -> void:
	_money_tween = null


func _on_player_hp_changed(current_hp: float, max_hp: float, _old_hp: float) -> void:
	_hp_progress_bar.max_value = max_hp
	_hp_progress_bar.value = current_hp


func _on_player_died() -> void:
	_dead_screen.visible = true


func _on_player_respawned(_spawn_global_position: Vector2) -> void:
	_dead_screen.visible = false
