extends "res://scripts/interact.gd"



func _interact(character: CharacterBody3D):
	character.sleep(global_transform)

func _get_action() -> String:
	return "Sleep"
