extends CharacterBody3D

@export var speed = 1.0
@export var rotationDegPerSecond = 60
@export var player: Node3D # TODO refactor

#func _ready() -> void:
#	look_at(player.global_position)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	var direction = player.global_position - global_position
	var target_angle_y = atan2(direction.x, direction.z)
	print(rad_to_deg(target_angle_y))
	var max_step_rad = deg_to_rad(rotationDegPerSecond) * delta
	# 2. Get the current and target Y rotation (in radians)
	var current_rot_y: float = rotation.y
	var angle_diff: float = wrapf(target_angle_y - current_rot_y, -PI, PI)
	
	# Calculate the fraction of the total difference that max_step represents
	var weight: float
	if abs(angle_diff) < max_step_rad:
		# If the remaining difference is smaller than the max step, move the full difference
		weight = 1.0
	else:
		# Otherwise, move by the max_step in the correct direction
		weight = max_step_rad / abs(angle_diff)
	
	# 4. Apply the rotation
	# lerp_angle ensures the shortest path is taken and uses the calculated weight
	rotation.y = lerp_angle(current_rot_y, target_angle_y, weight)
	
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()
