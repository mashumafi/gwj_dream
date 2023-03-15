extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _on_in_area_body_entered(body: Node3D) -> void:
	var character := body as CharacterBody3D
	if character and character.open_in($InArea.position.rotated(Vector3.UP, rotation.y)):
		animation_player.play("open_in")


func _on_out_area_body_entered(body: Node3D) -> void:
	var character := body as CharacterBody3D
	if character and character.open_out($OutArea.position.rotated(Vector3.UP, rotation.y)):
		animation_player.play("open_out")
