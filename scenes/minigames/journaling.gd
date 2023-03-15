extends "res://scripts/minigame.gd"

var next_key : String
var valid_keys := "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
var valid_key_count := 0

@onready var next_key_label := %next_key_label

func _ready() -> void:
	await get_tree().create_timer(1).timeout
	start()
	_choose_next_key()

func _input(event: InputEvent) -> void:
	var key_event := event as InputEventKey
	if key_event and key_event.pressed:
		var text_key_label := key_event.as_text_key_label()
		if text_key_label == next_key:
			_choose_next_key()
			valid_key_count += 1
		else:
			next_key_label.text = "ERROR"
			next_key = ""
			get_tree().create_timer(.5).timeout.connect(_choose_next_key)

func _choose_next_key():
	next_key = valid_keys[randi_range(0, valid_keys.length() - 1)]
	next_key_label.text = next_key

func _get_score() -> float:
	return min(valid_key_count, 12)
