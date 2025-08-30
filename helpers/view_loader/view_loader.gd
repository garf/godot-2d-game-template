class_name ViewLoader extends Node

var loading_view: LoadingView = null

var _is_loading: bool = true : set = set_is_loading
var next_scene_path: String = ''

func _enter_tree() -> void:
	Events.VIEW_load_view.connect(load_view)
	Events.VIEW_show_loading_view.connect(_show_loading_view)
	Events.VIEW_show_loading_text.connect(_set_loading_text)
	Events.VIEW_hide_loading_view.connect(_hide_loading_view)


func _ready() -> void:
	var loading_scene = ViewDb.get_view_scene(ViewDb.Keys.LOADING)
	loading_view = loading_scene.instantiate()
	add_child(loading_view)
	loading_view.set_loading_percentage(0.0)


func _process(_delta: float) -> void:
	if !_is_loading:
		return

	var progress = []
	var status := ResourceLoader.load_threaded_get_status(next_scene_path, progress)
	loading_view.set_loading_percentage(progress[0])

	if status == 3:
		var new_scene: PackedScene = ResourceLoader.load_threaded_get(next_scene_path)
		var new_scene_instance = new_scene.instantiate()
		add_child(new_scene_instance)
		_is_loading = false


func load_view(view: ViewDb.Keys) -> void:
	_unload_current_view()
	loading_view.set_loading_percentage(0.0)

	next_scene_path = ViewDb.get_view_scene_path(view)
	ResourceLoader.load_threaded_request(next_scene_path)
	_is_loading = true


func _unload_current_view() -> void:
	for child in get_children():
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
