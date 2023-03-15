extends Area3D

@export var meshes : Array[NodePath]

func _ready() -> void:
	return
	_setup_mesh_overrides()
	body_entered.connect(_body_entered)
	body_exited.connect(_body_exited)

func _body_entered(body: Object) -> void:
	var character := body as CharacterBody3D
	if character:
		set_mesh_mat_alpha(0.25)

func _body_exited(body: Object) -> void:
	var character := body as CharacterBody3D
	if character:
		set_mesh_mat_alpha(1.0)

func _setup_mesh_overrides() -> void:
	for path in meshes:
		var mesh_instance := get_node(path) as MeshInstance3D
		if mesh_instance:
			for i in mesh_instance.mesh.get_surface_count():
				var material := mesh_instance.mesh.surface_get_material(i).duplicate(true) as BaseMaterial3D
				if material:
					material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
					mesh_instance.set_surface_override_material(i, material)

func set_mesh_mat_alpha(value: float) -> void:
	for path in meshes:
		var mesh_instance := get_node(path) as MeshInstance3D
		if mesh_instance:
			for i in mesh_instance.get_surface_override_material_count():
				var material := mesh_instance.get_surface_override_material(i) as BaseMaterial3D
				if material:
					create_tween().tween_property(material, "albedo_color:a", value, .5)
