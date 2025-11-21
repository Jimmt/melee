extends CharacterBody3D

@export var speed = 5.0
@export var jump_velocity = 4.5
@export var mouse_sens = 0.0005
@export var raycast_length = 2
@export var incoming_attack_manager: Node3D

var input_accumulator = Vector2.ZERO
var head: Node3D
var sword: Node3D
var camera: Camera3D
var animation_player: AnimationPlayer
var debugDraw3DScopeConfig: DebugDraw3DScopeConfig

enum State {
	IDLE, ATTACKING, BLOCKING 
}
var applied_hit_map: Dictionary[Node3D, int] = {}
var state = State.IDLE

func _ready():
	# TODO: move this somewhere else...
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	head = $Head
	sword = head.get_node("sword")
	camera = head.get_node("Camera3D")
	animation_player = $Head/sword/AnimationPlayer
	debugDraw3DScopeConfig = DebugDraw3D.new_scoped_config().set_no_depth_test(true)
	
	animation_player.animation_finished.connect(on_anim_finished)

func on_anim_finished(name):
	state = State.IDLE
	
func _input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		input_accumulator += event.relative

func _physics_process(delta: float) -> void:		
	if Input.is_action_just_pressed("primary_attack"):
		applied_hit_map.clear()
		state = State.ATTACKING
		animation_player.play("Attack")
		
	if Input.is_action_just_pressed("block"):
		handle_block()
		
	if Input.is_action_just_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE else Input.MOUSE_MODE_VISIBLE
	
	rotation.y -= input_accumulator.x * mouse_sens
	head.rotation.x -= input_accumulator.y * mouse_sens
	head.rotation.x = deg_to_rad(clampf(rad_to_deg(head.rotation.x), -70, 89))
	input_accumulator = Vector2.ZERO
	
	move(delta)
	check_attack_raycast()
		
func handle_block():
	state = State.BLOCKING
	animation_player.play("Block")
	incoming_attack_manager.check_block()

# TODO: shapecast?
func check_attack_raycast():
	if state != State.ATTACKING:
		applied_hit_map.clear()
		return
	var played_ratio = animation_player.current_animation_position / animation_player.current_animation_length
	if played_ratio >= 0.8:
		return
	
	var space_state = get_world_3d().direct_space_state
	var origin = sword.get_node("BoneMarker").global_position
	var ray_marker = sword.get_node("BoneMarker").get_node("OffsetMarker").global_position
	var dir = (ray_marker - origin).normalized()
	var end = origin + dir * raycast_length
	var ray_query_params = PhysicsRayQueryParameters3D.create(origin, end)
	DebugDraw3D.draw_ray(origin, dir, raycast_length)
	var result = space_state.intersect_ray(ray_query_params)
	
	if result and result.collider.has_method("take_hit"):
		var hit_node = result.collider
		if applied_hit_map.get(hit_node):
			return
		hit_node.take_hit(hit_node.position, (hit_node.global_position - position).normalized())
		applied_hit_map[hit_node] = 1
	
func move(delta: float):
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (camera.global_basis.x * input_dir.x + camera.global_basis.z * input_dir.y).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()
