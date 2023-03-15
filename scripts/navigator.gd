extends Node

const day_transition := preload("res://scripts/day_transition.tres")
var day_transition_image := day_transition.get_image()

signal destination_requested(Vector3)
signal action_changed(String)
signal sleep_score_changed(float)

var destination: Object = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func set_destination(position: Vector3, object: Object = null) -> void:
	destination = object
	destination_requested.emit(position)

func set_action(action: String):
	action_changed.emit(action)

func clear_action():
	action_changed.emit("")

var SLEEP_SCORE := 0.0

func reset():
	SLEEP_SCORE = 0

func add_sleep_score(value: float) -> void:
	prints("added", value, "to sleep score")
	SLEEP_SCORE += value
	sleep_score_changed.emit(value)

func start_sleep_timer():
	await get_tree().create_timer(SLEEP_SCORE + 30.0).timeout
	transition_day()

func transition_day():
	SLEEP_SCORE = 0
	var tree := get_tree()
	tree.paused = true
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	var game := tree.root.get_node("game")
	var color_rect : ColorRect = game.get_node("ColorRect")
	tween.tween_property(color_rect, "color", day_transition_image.get_pixel(0, 0), 1)
	tween.tween_callback(func():
		game.get_node("dream").queue_free()
		var House := load("res://scenes/house.tscn")
		var house = House.instantiate()
		game.add_child(house)
		game.get_node("basicCharacter").global_transform = house.get_node("playerStart").global_transform
	)
	tween.tween_method(func(delta): color_rect.color = day_transition_image.get_pixel(delta, 0), 0, day_transition_image.get_width() - 1, 3)
	tween.tween_property(color_rect, "color", Color(0, 0, 0, 0), 1)
	tween.tween_callback(func():
		tree.paused = false
	)
