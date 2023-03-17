extends Node

const day_transition := preload("res://scripts/day_transition.tres")
var day_transition_image := day_transition.get_image()

signal destination_requested(Vector3)
signal action_changed(String)
signal happy_score_changed(float)
signal message_sent(String)

var destination: Object = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func set_destination(position: Vector3, object: Object = null) -> void:
	destination = object
	destination_requested.emit(position)

func set_action(action: String):
	action_changed.emit(action)

func can_interact() -> bool:
	return TIRED_SCORE < 100.0

func clear_action():
	set_action("")

var HAPPY_SCORE := 0.0
var TIRED_SCORE := 100.0

func reset_happy():
	HAPPY_SCORE = 0
	happy_score_changed.emit(HAPPY_SCORE)

func reset_sleep():
	TIRED_SCORE = 0.0

func add_happy_score(value: float) -> void:
	HAPPY_SCORE += value
	happy_score_changed.emit(HAPPY_SCORE)

func get_happy_timeout() -> float:
	return HAPPY_SCORE + 30.0

func start_happy_timer():
	await get_tree().create_timer(get_happy_timeout()).timeout
	transition_day()

func send_message(message: String) -> void:
	message_sent.emit(message)

func transition_day():
	var tree := get_tree()
	tree.paused = true
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	var game := tree.root.get_node("game")
	var color_rect : ColorRect = game.get_node("ColorRect")
	tween.tween_property(color_rect, "color", day_transition_image.get_pixel(0, 0), 1)
	tween.tween_callback(func():
		var viewport = game.get_node("SubViewportContainer/SubViewport")
		viewport.get_node("dream").queue_free()
		var House := load("res://scenes/house.tscn")
		var house = House.instantiate()
		viewport.add_child(house)
		var player = viewport.get_node("basicCharacter")
		player.global_transform = house.get_node("playerStart").global_transform
		player.set_skin_type(player.SkinType.MAN)
		Navigator.reset_happy()
		Navigator.reset_sleep()
		create_tween().tween_property(self, "TIRED_SCORE", 100, 60)
	)
	tween.tween_method(func(delta): color_rect.color = day_transition_image.get_pixel(delta, 0), 0, day_transition_image.get_width() - 1, 3)
	tween.tween_property(color_rect, "color", Color(0, 0, 0, 0), 1)
	tween.tween_callback(func():
		tree.paused = false
	)
