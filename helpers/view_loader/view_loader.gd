class_name ViewLoader extends Node

@export var content_parent_path: NodePath = NodePath(".")

var loading_view: LoadingView = null

var _is_loading: bool = false : set = set_is_loading
var next_scene_path: String = ''
var next_view: ViewDb.Keys = ViewDb.Keys.LOADING
var _content_parent: Node = null

func _enter_tree() -> void:
	Events.VIEW_load_view.connect(load_view)
	Events.VIEW_show_loading_view.connect(_show_loading_view)
	Events.VIEW_show_loading_text.connect(_set_loading_text)
	Events.VIEW_hide_loading_view.connect(_hide_loading_view)


func _exit_tree() -> void:
	if Events.VIEW_load_view.is_connected(load_view):
		Events.VIEW_load_view.disconnect(load_view)
	if Events.VIEW_show_loading_view.is_connected(_show_loading_view):
		Events.VIEW_show_loading_view.disconnect(_show_loading_view)
	if Events.VIEW_show_loading_text.is_connected(_set_loading_text):
		Events.VIEW_show_loading_text.disconnect(_set_loading_text)
	if Events.VIEW_hide_loading_view.is_connected(_hide_loading_view):
		Events.VIEW_hide_loading_view.disconnect(_hide_loading_view)


func _ready() -> void:
	_content_parent = get_node_or_null(content_parent_path)
	if _content_parent == null:
		_content_parent = self

	var loading_scene: PackedScene = ViewDb.get_view_scene(ViewDb.Keys.LOADING)
	loading_view = loading_scene.instantiate()
	add_child(loading_view)
	loading_view.set_loading_percentage(0.0)


func _process(_delta: float) -> void:
	if !_is_loading or next_scene_path.is_empty():
		return

	var progress: Array[float] = []
	var status: int = ResourceLoader.load_threaded_get_status(next_scene_path, progress)
	var loaded_percentage: float = progress[0] if not progress.is_empty() else 0.0
	loading_view.set_loading_percentage(loaded_percentage)

	if status == ResourceLoader.THREAD_LOAD_LOADED:
		var new_scene: PackedScene = ResourceLoader.load_threaded_get(next_scene_path)
		if new_scene == null:
			push_error("Loaded view path is not a PackedScene: %s" % next_scene_path)
			_is_loading = false
			return

		var new_scene_instance: Node = new_scene.instantiate()
		_content_parent.add_child(new_scene_instance)
		_is_loading = false
		Events.VIEW_view_loaded.emit(next_view)
	elif status == ResourceLoader.THREAD_LOAD_FAILED or status == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
		push_error("Failed to load view path: %s" % next_scene_path)
		_is_loading = false


func load_view(view: ViewDb.Keys) -> void:
	_unload_current_view()
	loading_view.set_loading_percentage(0.0)

	next_view = view
	next_scene_path = ViewDb.get_view_scene_path(view)
	if next_scene_path.is_empty():
		push_error("View has no scene path: %s" % ViewDb.Keys.keys()[view])
		return

	var error: Error = ResourceLoader.load_threaded_request(next_scene_path)
	if error != OK:
		push_error("Failed to request threaded view load: %s" % next_scene_path)
		return

	_is_loading = true


func _unload_current_view() -> void:
	for child in _content_parent.get_children():
		# Skip loading view node
		if child is not LoadingView:
			child.queue_free()


func _hide_loading_view() -> void:
	loading_view.visible = false


func _show_loading_view(percentage: float) -> void:
	loading_view.visible = true
	loading_view.set_loading_text('Loading...')
	loading_view.set_loading_percentage(percentage)


func _set_loading_text(loading_text: String = 'Loading...') -> void:
	loading_view.set_loading_text(loading_text)


func set_is_loading(state: bool) -> void:
	if _is_loading == state:
		return

	_is_loading = state
	if state:
		_show_loading_view(0.0)
	else:
		_hide_loading_view()
