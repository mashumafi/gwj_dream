extends Node

@onready var action_label := %actionLabel
@onready var tiredness_progress := %TirednessProgress
@onready var happiness_progress := %HappinessProgress
@onready var message_label := %Message
@onready var message_timer := %MessageTimer

func _ready() -> void:
	Navigator.action_changed.connect(_action_changed)
	Navigator.happy_score_changed.connect(_happy_score_changed)
	Navigator.message_sent.connect(_message_sent)

func _action_changed(action: String) -> void:
	action_label.text = action

func _happy_score_changed(value: float):
	happiness_progress.value = value

func _process(delta: float) -> void:
	tiredness_progress.value = Navigator.TIRED_SCORE

func _message_sent(message: String):
	message_label.text = message
	message_timer.start(5 + message.length() / 2.0)


func _on_message_timer_timeout() -> void:
	message_label.text = ""
