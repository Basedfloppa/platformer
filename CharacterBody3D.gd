extends CharacterBody3D

@export var base_spd = 5.0
@export var base_fov = 80.0
@export var run_spd = 7.0
@export var mouse_sensivity = 0.1

const JUMP_VELOCITY = 4
const max_double_jump = 1
const gravity = 9.8
const deceleration = 2

var spd = base_spd
var on_wall = false
var double_jump = 1

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func _input(event):
	if event is InputEventMouseMotion:
		$Camera.rotation_degrees.x -= event.relative.y * mouse_sensivity
		$Camera.rotation_degrees.x = clamp($Camera.rotation_degrees.x, -90, 90)
		rotation_degrees.y -= event.relative.x * mouse_sensivity
	if Input.is_action_just_pressed("escape"):
		get_tree().quit() 

func _physics_process(delta):
	movement(delta)

#falling out of the world
func _on_respawn_body_entered(body):
	if body.name=="player":
		body.position = Vector3(0,7,0)

#additional jump on touching special geometry
func _on_area_body_entered(body):
	if body.get_groups().has("SpecialGeometry"):
		double_jump += 1

#movement handling
func movement(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta * (1.5 if velocity.y > 0 else 1.0)
	else:
		double_jump = max_double_jump

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and (is_on_floor() or double_jump >= 1):
		velocity.y = JUMP_VELOCITY
		if not is_on_floor() and double_jump >= 1: double_jump -= 1
	if Input.is_action_pressed("run"):
		$Camera.fov = lerpf($Camera.fov, base_fov + 10, 0.1)
		spd = clamp(spd + (2 * delta),base_spd,100)
	else:
		$Camera.fov = lerpf($Camera.fov, base_fov, 0.2)
		spd = lerpf(spd, base_spd, 0.1)
	
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * spd
		velocity.z = direction.z * spd
	else:
		velocity.x = lerpf(velocity.x + spd * deceleration * ((1 - pow(deceleration, delta)) / (1 - deceleration)) * delta, 0, 0.1)
		velocity.z = lerpf(velocity.z + spd * deceleration * ((1 - pow(deceleration, delta)) / (1 - deceleration)) * delta, 0, 0.1)
	
	var camera_vec3 = $Camera.get_global_transform().basis.z	
	var camera_2d = Vector2(camera_vec3.x,camera_vec3.z)
	var velocity_2d = Vector2(velocity.x,velocity.z)
	var ang = abs(rad_to_deg(camera_2d.angle_to(velocity_2d)))
	if ang <= 90 and ang >= 46:
		spd = spd * 0.7
	elif ang >= 0 and ang <= 45:
		spd = spd * 0.5
	
	move_and_slide()
	
