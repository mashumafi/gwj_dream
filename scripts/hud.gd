extends Node

@onready var action_label := %actionLabel

func _ready() -> void:
	Navigator.action_changed.connect(_action_changed)

func _action_changed(action: String) -> void:
	action_label.text = action
