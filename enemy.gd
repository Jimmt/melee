extends CharacterBody3D

@export var speed = 1.0
@export var rotationDegPerSecond = 100
@export var player: Node3D # TODO refactor
@export var min_distance = 1.55
@export var push_back_dist = 0.4
@onready var animation_player: AnimationPlayer = $sword/AnimationPlayer
var lock_move = false

enum State {
	IDLE, ATTACKING, BLOCKING 
}
var state = State.IDLE
var last_attack_finish_time = 0

func _ready():
	animation_player.animation_finished.connect(on_anim_finished)

func on_anim_finished(name):
	if name == "Attack":
		last_attack_finish_time = Time.get_ticks_msec()
	state = State.IDLE

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if lock_move:
		return

	var direction: Vector3 = player.global_position - global_position
	var current_forward: Vector3 = -transform.basis.z.normalized()
	var angle_diff: float = current_forward.signed_angle_to(direction, Vector3.UP)
	
	var max_step_rad: float = deg_to_rad(rotationDegPerSecond) * delta
	
	var rotation_amount: float
	if abs(angle_diff) < max_step_rad:
		rotation_amount = angle_diff
	else:
		rotation_amount = sign(angle_diff) * max_step_rad
	
	rotation.y += rotation_amount
	
	if direction.length() > min_distance:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		attack()
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()
	
func attack():
	var time_since_last_attack_finish = Time.get_ticks_msec() - last_attack_finish_time
	if state == State.ATTACKING || time_since_last_attack_finish < 500:
		return
	state = State.ATTACKING
	animation_player.play("Attack")
	
func take_hit(position: Vector3, direction: Vector3):
	lock_move = true
	
	var push_back = direction * push_back_dist
	push_back.y = 0
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", global_position + push_back, 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_callback(func():
		await get_tree().create_timer(0.5).timeout
		lock_move = false
	)
