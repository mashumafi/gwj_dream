extends "res://scripts/minigame.gd"

@onready var flameArea := %flameArea
@onready var flameMarkers := %flameMarkers

var _is_inside := false
var _seconds_inside := 0.0

func _first_entered() -> void:
	print("Starting in 1 second")
	var tween := get_tree().create_tween()
	await get_tree().create_timer(1).timeout
	start()
	tween = get_tree().create_tween()
	for i in 4:
		var markerIndex := randi_range(0, flameMarkers.get_child_count() - 1)
		tween.tween_property(flameArea, "position", flameMarkers.get_child(markerIndex).position, 3).set_ease(Tween.EASE_IN_OUT).set_delay(.5)

func _entered() -> void:
	_is_inside = true

func _exited() -> void:
	_is_inside = false

func _process(delta: float) -> void:
	if _is_inside:
		_seconds_inside += delta

func _get_score() -> float:
	return floor(_seconds_inside / 2.0)
