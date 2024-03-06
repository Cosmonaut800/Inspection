extends CharacterBody3D


const SPEED = 5.0
const ACCEL = 25.0
const DECEL = 25.0

@onready var yaw := $YawPivot
@onready var pitch := $YawPivot/PitchPivot
@onready var camera := $YawPivot/PitchPivot/Camera3D
@onready var ray := $YawPivot/PitchPivot/RayCast3D

var current_cabinet: Node3D
var previous_basis: Basis
var previous_position: Vector3

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var mouse_sensitivity := 0.002
var yaw_input := 0.0
var pitch_input := 0.0

var state := 0
enum STATE {FREE, IN_CABINET}

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	state = STATE.FREE

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = (yaw.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	direction.y = 0.0
	if state == STATE.FREE and direction:
		velocity.x = move_toward(velocity.x, SPEED * direction.x, ACCEL * delta)
		velocity.z = move_toward(velocity.z, SPEED * direction.z, ACCEL * delta)
	elif state != STATE.FREE:
		velocity = Vector3.ZERO
	else:
		velocity.x = move_toward(velocity.x, 0, DECEL * delta)
		velocity.z = move_toward(velocity.z, 0, DECEL * delta)

	move_and_slide()

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if Input.is_action_just_pressed("use"):
		if state == STATE.FREE and ray.is_colliding():
			previous_basis = camera.global_basis
			previous_position = camera.position
			current_cabinet = ray.get_collider().get_parent()
			current_cabinet.open_cabinet()
			camera.global_basis = current_cabinet.cam_target.global_basis
			camera.global_position = current_cabinet.cam_target.global_position
			state = STATE.IN_CABINET
			
		elif state == STATE.IN_CABINET:
			camera.global_basis = previous_basis
			camera.position = previous_position
			current_cabinet.close_cabinet()
			state = STATE.FREE
	
	if state == STATE.FREE:
		yaw.rotate_y(yaw_input)
		pitch.rotate_x(pitch_input)
		pitch.rotation.x = clamp(pitch.rotation.x, -1.5, 1.5)
		yaw_input = 0.0
		pitch_input = 0.0

func _unhandled_input(event):
		if event is InputEventMouseMotion:
			if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
				yaw_input = -event.relative.x * mouse_sensitivity
				pitch_input = -event.relative.y * mouse_sensitivity
