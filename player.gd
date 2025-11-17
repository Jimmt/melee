extends CharacterBody3D

@export var speed = 5.0
@export var jump_velocity = 4.5
@export var mouse_sens = 0.00075

var input_accumulator = Vector2.ZERO
var head: Node3D
var camera: Camera3D
var debugDraw3DScopeConfig: DebugDraw3DScopeConfig

func _ready():
	# TODO: move this somewhere else...
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	head = $Head
	camera = head.get_node("Camera3D")
	debugDraw3DScopeConfig = DebugDraw3D.new_scoped_config().set_no_depth_test(true)

	
func _input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		input_accumulator += event.relative

func _physics_process(delta: float) -> void:	
	if Input.is_action_just_pressed("primary_attack"):
		$Head/sword/AnimationPlayer.play("Attack")
		
	if Input.is_action_just_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE else Input.MOUSE_MODE_VISIBLE
	
	rotation.y -= input_accumulator.x * mouse_sens
	head.rotation.x -= input_accumulator.y * mouse_sens
	head.rotation.x = deg_to_rad(clampf(rad_to_deg(head.rotation.x), -70, 89))
	input_accumulator = Vector2.ZERO
	
	move(delta)
	
#	DebugDraw3D.draw_ray(position + Vector3.UP * 0.1, -camera.global_basis.z, 5)
	
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
