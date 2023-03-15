extends CharacterBody3D

@onready var skeleton := $basicCharacter/basicCharacter2/Skeleton3D as Skeleton3D

const Dream := preload("res://scenes/dream.tscn")

@onready var animation_tree := $AnimationTree as AnimationTree
@onready var anim_player: AnimationPlayer = $basicCharacter/AnimationPlayer
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var move_particles: CPUParticles3D = $basicCharacter/move_particles
@onready var state_label: Label3D = $state_label
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var root_animation := $basicCharacter

enum SkinType {
	MAN,
	ADVENTURER,
}

enum State {
	MOVE,
	OPEN_DOOR,
	LAY
}
var state := State.MOVE

func _ready() -> void:
	set_skin_type(SkinType.MAN)
	animation_tree.animation_finished.connect(_animation_finished)

	animation_tree["parameters/transition/transition_request"] = "move"
	nav_agent.velocity_computed.connect(_velocity_computed)
	animation_tree["parameters/move/blend_position"] = 0

	nav_agent.target_position = global_position
	Navigator.destination_requested.connect(func(destination):
		nav_agent.target_position = destination
	)

func _animation_finished(anim_name: String) -> void:
	if anim_name in ["open_in", "open_out"]:
		state = State.MOVE
	elif anim_name == "lay":
		
		var structure := $"../house/structure"
		var bed := $"../house/bedSingle"
		var tween := create_tween()
		tween.tween_property(structure, "position", Vector3.DOWN * 1000, 3).set_ease(Tween.EASE_OUT)
		tween.parallel().tween_property(bed, "position", Vector3.DOWN * 1000, 3).set_ease(Tween.EASE_OUT).set_delay(1)
		tween.parallel().tween_callback($"../house".queue_free).set_delay(4)
		tween.parallel().tween_callback(set_skin_type.bind(SkinType.ADVENTURER)).set_delay(4)
		tween.parallel().tween_property(root_animation, "rotation", Vector3(0, 0, 0), 1).set_delay(4)
		tween.parallel().tween_callback(func(): state = State.MOVE).set_delay(4.5)
		tween.parallel().tween_callback(func(): nav_agent.target_position = global_position).set_delay(4.5)
		var dream = Dream.instantiate()
		dream.position = position
		dream.position.y = Vector3.DOWN.y * 1000
		get_node("..").add_child(dream)
		tween.parallel().tween_property(dream, "position:y", 0, 1).set_delay(3)
		tween.parallel().tween_callback(Navigator.start_sleep_timer).set_delay(4.5)

func set_skin_type(skin_type: SkinType) -> void:
	var skin_material := StandardMaterial3D.new()
	match skin_type:
		SkinType.MAN:
			skin_material.albedo_texture = preload("res://models/basicCharacter/skin_man.png")
		SkinType.ADVENTURER:
			skin_material.albedo_texture = preload("res://models/basicCharacter/skin_adventurer.png")

	for node in skeleton.get_children():
		var mesh := node as MeshInstance3D
		if mesh:
			mesh.set_surface_override_material(0, skin_material)

func _velocity_computed(safe_velocity: Vector3):
	velocity = safe_velocity
	move_and_slide()

func scale_move_towards(value: float) -> void:
	var blend_position := float(animation_tree["parameters/move/blend_position"])
	animation_tree["parameters/move/blend_position"] = lerp(blend_position, value, .1)

func _physics_process(delta: float) -> void:
	match state:
		State.MOVE:
			if nav_agent.is_navigation_finished():
				state_label.text = "idle"
				scale_move_towards(0.0)
				move_particles.emitting = false
				velocity = Vector3.ZERO
			else:
				move_particles.emitting = true
				var velocity_xz := Vector2(velocity.x, -velocity.z)
				root_animation.rotation = Vector3(0, velocity_xz.angle() + PI / 2, 0)
				var nav_velocity := nav_agent.get_next_path_position() - global_position
				nav_velocity = nav_velocity.normalized() * 2
				nav_agent.set_velocity(nav_velocity)
				animation_tree["parameters/transition/transition_request"] = "move"
				scale_move_towards(1.0)
				state_label.text = "walk"

func open_out(target: Vector3) -> bool:
	if state != State.MOVE:
		return false

	state_label.text = "open out"

	move_particles.emitting = false
	animation_tree["parameters/move/blend_position"] = 0
	state = State.OPEN_DOOR
	var target_xz := Vector2(target.x, -target.z)
	root_animation.rotation = Vector3(0, target_xz.angle() + PI / 2, 0)
	
	animation_tree["parameters/open_out/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
	create_tween().tween_property(self, "global_position", global_position - Vector3.FORWARD.rotated(Vector3.UP, root_animation.rotation.y) * .75, 1).set_delay(2.5)
	return true

func open_in(target: Vector3) -> bool:
	if state != State.MOVE:
		return false

	state_label.text = "open in"

	move_particles.emitting = false
	animation_tree["parameters/move/blend_position"] = 0
	state = State.OPEN_DOOR
	var target_xz := Vector2(target.x, -target.z)
	root_animation.rotation = Vector3(0, target_xz.angle() + PI / 2, 0)
	animation_tree["parameters/open_in/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
	create_tween().tween_property(self, "global_position", global_position - Vector3.FORWARD.rotated(Vector3.UP, root_animation.rotation.y) * .75, 1).set_delay(2.5)
	return true

func sleep(sleep_transform: Transform3D) -> void:
	state_label.text = "sleep"
	state = State.LAY
	move_particles.emitting = false
	global_transform = sleep_transform
	animation_tree["parameters/transition/transition_request"] = "lay"
	root_animation.rotation = Vector3(-PI/2, 0, 0)
	translate(Vector3(0, .5, .75))
