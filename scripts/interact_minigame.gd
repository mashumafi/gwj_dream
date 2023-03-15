extends "interact.gd"

@export var action := ""
@export var minigame : PackedScene

func _interact(character: CharacterBody3D):
	if not minigame:
		printerr("No minigame set")
		return

	var scene := minigame.instantiate()
	get_tree().root.get_node("game").add_child(scene)

func _get_action() -> String:
	return action
