extends Area3D

@export var outline_mesh : MeshInstance3D

func _ready() -> void:
	body_entered.connect(_body_entered)

func _input_event(camera: Camera3D, event: InputEvent, destination: Vector3, normal: Vector3, shape_idx: int) -> void:
	var mouse_button := event as InputEventMouseButton
	if mouse_button and mouse_button.pressed:
		Navigator.set_destination(global_position, self)

func _mouse_enter() -> void:
	if not outline_mesh:
		printerr("No outline selected")
		return

	Navigator.set_action(_get_action())

	outline_mesh.visible = true

func _mouse_exit() -> void:
	if not outline_mesh:
		printerr("No outline selected")
		return

	Navigator.clear_action()

	outline_mesh.visible = false

func _body_entered(body: Object) -> void:
	var character := body as CharacterBody3D
	if character and Navigator.destination == self:
		_interact(character)
		queue_free()
		_mouse_exit()

func _interact(character: CharacterBody3D):
	pass

func _get_action() -> String:
	return "undefined"
