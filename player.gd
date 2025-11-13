extends CharacterBody3D


@export var speed = 5.0
@export var jump_velocity = 4.5
@export var mouse_sens = 0.01

var input_accumulator = Vector2.ZERO

func _ready():
	# TODO: move this somewhere else...
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _input(event):
	if event is InputEventMouseMotion:
		print(event.relative)
		input_accumulator += event.relative

func _physics_process(delta: float) -> void:
	move(delta)
	
	if Input.is_action_just_pressed("primary_attack"):
		print("attack")
		
	rotation.y -= input_accumulator.x * mouse_sens 
	input_accumulator = Vector2.ZERO
	
func move(delta: float):
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()
