extends Area3D

@export var outline_mesh : VisualInstance3D

func _ready() -> void:
	body_entered.connect(_body_entered)

func _input_event(camera: Camera3D, event: InputEvent, destination: Vector3, normal: Vector3, shape_idx: int) -> void:
	var mouse_button := event as InputEventMouseButton
	if mouse_button and mouse_button.pressed:
		Navigator.set_destination(global_position, self)

func _mouse_enter() -> void:
	if outline_mesh:
		outline_mesh.visible = true
	else:
		printerr("No outline selected")

	Navigator.set_action(_get_action())

func _mouse_exit() -> void:
	if outline_mesh:
		outline_mesh.visible = false
	else:
		printerr("No outline selected")

	Navigator.clear_action()

func _body_entered(body: Object) -> void:
	var character := body as CharacterBody3D
	if character and Navigator.destination == self:
		var the_name = name
		if Navigator.can_interact() or name == "bedInteraction":
			_interact(character)
			_mouse_exit()
		else:
			Navigator.set_action("Too tired")

		if _one_shot():
			queue_free()

func _interact(character: CharacterBody3D):
	pass

func _get_action() -> String:
	return "undefined"

func _one_shot() -> bool:
	return true
