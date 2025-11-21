extends Node3D

@export var control_node: Node
var incoming_attack_indicator: PackedScene = preload("res://incoming_attack_indicator.tscn")

signal enemy_attack_blocked()

func _process(delta: float) -> void:
	var camera = get_viewport().get_camera_3d()
	for n in get_children():
		n.global_rotation = camera.global_rotation

func check_block():
	for n in get_children():
		if n.mesh is QuadMesh:
			_check_quad(n)
		else:
			push_error("Incoming attack mesh is not a QuadMesh")
			
func _check_quad(quad: Node3D):
	var mesh: QuadMesh = quad.mesh
	var half = mesh.size / 2
	var local_corners = [
		Vector3(-half.x,  half.y, 0),  # top-left in world XY
		Vector3( half.x,  half.y, 0),  # top-right
		Vector3(-half.x, -half.y, 0),  # bottom-left
		Vector3( half.x, -half.y, 0)   # bottom-right
	]
	var screen_corners: Array[Vector2] = []
	
	var camera = get_viewport().get_camera_3d()
	for corner in local_corners:
		var world_pos: Vector3 = quad.global_transform * corner
		var screen_pos: Vector2 = camera.unproject_position(world_pos)
		screen_corners.append(screen_pos)
	
	var center_screen = camera.unproject_position(quad.global_position)
	var half_size_x = (screen_corners[1].x - screen_corners[0].x) / 2
	var half_size_y = (screen_corners[2].y - screen_corners[0].y) / 2
	var rect = Rect2(center_screen - Vector2(half_size_x, half_size_y),
		 Vector2(half_size_x * 2, half_size_y * 2))
	var reticle_pos = get_viewport().get_visible_rect().size / 2
	control_node.update_debug_rect(rect)

	if rect.has_point(reticle_pos):
		emit_signal("enemy_attack_blocked")

func _on_enemy_attack_start(attack_id: int, sword_pos: Vector3) -> void:
	var indicator = incoming_attack_indicator.instantiate()
	add_child(indicator)
	indicator.global_position = sword_pos

func _on_enemy_attack_pos(attack_id: int, sword_pos: Vector3) -> void:
	pass


func _on_enemy_attack_end(attack_id: int) -> void:
	# todo lookup map.
	for n in get_children():
		remove_child(n)
		n.queue_free()
