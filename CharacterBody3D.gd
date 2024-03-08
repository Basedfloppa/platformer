extends CharacterBody3D

@onready var Anim = $AnimationTree["parameters/playback"]
@onready var log = $"../Control/Label"

@export var jump_buffer		: float = 0.1
@export var coyote_time		: float = 0.1
@export var base_spd 		: int   = 10
@export var run_spd 		: int   = 20
@export var max_spd 		: int   = 50
@export var max_double_jump : int   = 1
@export var gravity 		: int   = 10
@export var deceleration 	: int   = 2

const JUMP_VELOCITY : int = 15

var spd : float = base_spd
var on_wall : bool = false
var double_jump : int = 1
var time_in_jump : float = 0.0
var starting_position : Vector3 = Vector3.ZERO

func _physics_process(delta):
	movement(delta)
	animation()

#movement handling
func movement(delta):
	# Add the gravity.
	if not is_on_floor():
		if velocity.y > 0 : time_in_jump += delta
		coyote_time -= delta
		velocity.y -= (gravity * global_position.distance_to(starting_position)) * delta + (time_in_jump * delta)
	else:
		coyote_time = 0.1
		double_jump = max_double_jump
	
	# Handle Jump.
	if Input.is_action_just_pressed("jump") and (is_on_floor() or double_jump >= 1 or coyote_time >= 0):
		time_in_jump = 0
		starting_position = global_position
		velocity.y = JUMP_VELOCITY
		if not is_on_floor():
			if double_jump >= 1: double_jump -= 1
	
	if Input.is_action_pressed("run"):
		spd = clamp(spd + (2 * delta),base_spd,max_spd)
	else:
		spd = lerpf(spd, base_spd, 0.1)
	
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * spd
		velocity.z = direction.z * spd
	else:
		velocity.x = lerpf(velocity.x + spd * deceleration * ((1 - pow(deceleration, delta)) / (1 - deceleration)) * delta, 0, 0.1)
		velocity.z = lerpf(velocity.z + spd * deceleration * ((1 - pow(deceleration, delta)) / (1 - deceleration)) * delta, 0, 0.1)
	
	if velocity: 
		var camera_vec3 = $Camera.get_global_transform().basis.z	
		var camera_2d = Vector2(camera_vec3.x,camera_vec3.z)
		var velocity_2d = Vector2(velocity.x,velocity.z)
		var ang = abs(floor(rad_to_deg(camera_2d.angle_to(velocity_2d))))
		if ang <= 90 and ang >= 46:
			spd *= 0.8
		elif ang >= 0 and ang <= 45:
			spd *= 0.7 
	
	move_and_slide()

#animation handling
func animation():
	if is_on_floor():
		var vec = abs(velocity.z) + abs(velocity.x)
		log.text = str(vec)
		if vec < 0.09:
			Anim.travel("Idle")
		else:
			if vec > 0 and vec <= 10:
				Anim.travel("SlowRun")
			if vec > 20 and vec <= 30:
				Anim.travel("Running")
			if vec > 30:
				Anim.travel("FastRun")
	else:
		Anim.travel("Jumping")
