class_name LoadingView extends CanvasLayer

@onready var loading_text: Label = %LoadingText
@onready var loaded_progress_bar: ProgressBar = %LoadedProgressBar


func set_loading_percentage(percentage: float) -> void:
	loaded_progress_bar.value = clampf(percentage * 100.0, 0.0, 100.0)


func set_loading_text(text: String = 'Loading...') -> void:
	loading_text.text = text
