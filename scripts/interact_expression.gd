@tool
extends "res://scripts/interact.gd"

@export var base_instance : Node
@export var action := ""
@export var score := 0.0

@export var expression : String :
	get:
		return expression
	set(value):
		var parser := Expression.new()
		var result := parser.parse(value)
		if result != OK:
			printerr("Error parsing expression {0}".format([parser.get_error_text()]))
		expression = value

func _interact(character: CharacterBody3D):
	var parser := Expression.new()
	var result := parser.parse(expression)
	if result != OK:
		printerr("Error parsing expression {0}".format([parser.get_error_text()]))
		return
	parser.execute([], base_instance)
	Navigator.add_happy_score(score)

func _get_action() -> String:
	return action
