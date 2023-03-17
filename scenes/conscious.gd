extends "res://scripts/interact.gd"

@onready var skeleton := $basicCharacter/basicCharacter2/Skeleton3D

@export var dialog : Array[Dialog] = []

func _ready() -> void:
	super()
	var skin_material := StandardMaterial3D.new()
	skin_material.albedo_texture = preload("res://models/basicCharacter/skin_man.png")

	for node in skeleton.get_children():
		var mesh := node as MeshInstance3D
		if mesh:
			mesh.set_surface_override_material(0, skin_material)

func _interact(character: CharacterBody3D):
	for d in dialog:
		var condition := Expression.new()
		var rc := condition.parse(d.condition)
		if rc != OK:
			printerr("Failed parsing ", condition.get_error_text())
			continue

		if condition.execute([], self):
			print(d.text)
			Navigator.send_message(d.text)
			break

func _get_action() -> String:
	return "Talk"

func _one_shot() -> bool:
	for d in dialog:
		var condition := Expression.new()
		var rc := condition.parse(d.condition)
		if rc != OK:
			printerr("Failed parsing ", condition.get_error_text())
			continue

		if condition.execute([], self):
			return false

	return true

func get_happiness() -> float:
	return Navigator.HAPPY_SCORE
