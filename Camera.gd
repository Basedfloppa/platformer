extends Camera3D

@export var base_fov : float = 80.0
@export var mouse_sensivity : float = 0.1

@onready var player = $".."
@onready var base_spd : float = player.base_spd
@onready var spd_diff : float = base_spd / player.max_spd

var camera_slowness : float
var player_velocity : float

func _process(_delta):
	player_velocity = floor(abs(player.velocity.x + player.velocity.z))
	fov = lerpf(fov, base_fov + player_velocity, 0.1)

func _input(event):
	if event is InputEventMouseMotion:
		rotation_degrees.x -= event.relative.y * mouse_sensivity
		rotation_degrees.x = clamp(rotation_degrees.x, -90, 90)
		camera_slowness = clamp( 1 - (player.spd / spd_diff) if player.spd > player.base_spd else 1.0, 0.5, 1)
		player.rotation_degrees.y -= event.relative.x * mouse_sensivity * camera_slowness
