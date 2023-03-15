extends CollisionObject3D

func _input_event(camera: Camera3D, event: InputEvent, destination: Vector3, normal: Vector3, shape_idx: int) -> void:
	var mouse_button := event as InputEventMouseButton
	if mouse_button and mouse_button.pressed:
		Navigator.set_destination(destination)
