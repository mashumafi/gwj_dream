extends Node

@export var progress_bar : ProgressBar

var timer : SceneTreeTimer

func start() -> void:
	if not progress_bar:
		printerr("No progress bar set")
		return

	timer = get_tree().create_timer(progress_bar.max_value)

	timer.timeout.connect(_timeout)

	progress_bar.value = progress_bar.max_value

func _process(delta: float) -> void:
	if not progress_bar:
		return

	if not timer:
		return

	progress_bar.value = timer.time_left

func _timeout():
	Navigator.add_happy_score(_get_score())
	queue_free()

func _get_score() -> float:
	return 0.0
