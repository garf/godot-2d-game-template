class_name GameView extends Node2D

const GAME_VIEWPORT_SIZE: Vector2i = Vector2i(480, 270)

@onready var _pixel_viewport_container: SubViewportContainer = %PixelViewportContainer
@onready var _world_viewport: SubViewport = %WorldViewport
@onready var _player: Player = %Player
@onready var _respawn_point: Marker2D = $PixelViewportContainer/WorldViewport/WorldRoot/ForestMap/RespawnPoint


func _ready() -> void:
	_configure_pixel_rendering()
	_pixel_viewport_container.stretch = true
	_update_pixel_viewport_layout()
	get_viewport().size_changed.connect(_update_pixel_viewport_layout)
	_request_player_respawn()
	#MusicPlayer.play_file(MusicDb.Keys.DAISY_DANCE, true)


func _exit_tree() -> void:
	if get_viewport().size_changed.is_connected(_update_pixel_viewport_layout):
		get_viewport().size_changed.disconnect(_update_pixel_viewport_layout)


func _process(_delta: float) -> void:
	if _player.is_dead() and Input.is_action_just_pressed("restart"):
		_request_player_respawn()


func _request_player_respawn() -> void:
	Events.PLAYER_respawn_requested.emit(_respawn_point.global_position)


func _configure_pixel_rendering() -> void:
	_pixel_viewport_container.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_world_viewport.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	_world_viewport.canvas_item_default_texture_repeat = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_REPEAT_DISABLED

	var world_viewport_rid: RID = _world_viewport.get_viewport_rid()
	RenderingServer.viewport_set_snap_2d_transforms_to_pixel(world_viewport_rid, true)
	RenderingServer.viewport_set_snap_2d_vertices_to_pixel(world_viewport_rid, false)


func _update_pixel_viewport_layout() -> void:
	var available_size: Vector2 = get_viewport().get_visible_rect().size
	var scale_x: int = floori(available_size.x / float(GAME_VIEWPORT_SIZE.x))
	var scale_y: int = floori(available_size.y / float(GAME_VIEWPORT_SIZE.y))
	var viewport_scale: int = maxi(1, mini(scale_x, scale_y))
	var presentation_size: Vector2 = Vector2(GAME_VIEWPORT_SIZE * viewport_scale)

	_pixel_viewport_container.size = presentation_size
	_pixel_viewport_container.position = ((available_size - presentation_size) * 0.5).floor()
	_pixel_viewport_container.stretch_shrink = viewport_scale
