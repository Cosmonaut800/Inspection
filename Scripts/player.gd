extends CharacterBody3D


const SPEED = 5.0
const ACCEL = 25.0
const DECEL = 25.0

@export var part_models: Array[Node3D] = []

@onready var yaw := $YawPivot
@onready var pitch := $YawPivot/PitchPivot
@onready var camera := $YawPivot/PitchPivot/Camera3D
@onready var cam_target := $YawPivot/PitchPivot/CameraTarget
@onready var ray := $YawPivot/PitchPivot/RayCast3D
@onready var action_wait := $ActionWait
@onready var footstep_timer := $Audio/FootstepTimer
@onready var footsteps := [	$Audio/footstep1,
							$Audio/footstep2,
							$Audio/footstep3,
							$Audio/footstep4]

var current_cabinet: Node3D
var previous_basis: Basis
var previous_position: Vector3

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var horizontal_speed := 1.0
var vertical_speed := 1.0
var mouse_sensitivity := 0.002
var yaw_input := 0.0
var pitch_input := 0.0

var state := 0
enum STATE {FREE, IN_CABINET}
var holding_part := false

var focused := true

var can_step := true
var can_use := true
var can_read_text := true

signal airlock_submitted(correct: bool)
signal next_text
signal show_tooltip(show: bool)
signal took_coffee

var model := 3
var coffee := true

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
	
	if can_step && get_last_motion().length() > 0.05:
		var index = randi_range(0, 3)
		can_step = false
		footstep_timer.start()
		footsteps[index].pitch_scale = randf_range(0.9, 1.1)
		footsteps[index].play()
	
	move_and_slide()

func _process(_delta):
	var entity;
	
	#if Input.is_action_just_pressed("ui_cancel"):
		#if focused:
			#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		#else:
			#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		#
		#focused = !focused
	
	if !focused and Input.is_action_just_pressed("dismiss_text"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		focused = true
	
	if focused and Input.is_action_just_pressed("use") and can_use:
		if state == STATE.FREE and ray.is_colliding():
			entity = ray.get_collider().get_parent()
			if entity.entity_type == "inspection_frame":
				show_tooltip.emit(false)
				current_cabinet = entity
				previous_basis = cam_target.global_basis
				previous_position = cam_target.position
				current_cabinet.open_cabinet()
				cam_target.global_basis = current_cabinet.cam_target.global_basis
				cam_target.global_position = current_cabinet.cam_target.global_position
				camera.weight = 0.0
				camera.fov = 60.0
				state = STATE.IN_CABINET
				model = current_cabinet.model
			elif holding_part and entity.entity_type == "air_lock":
				holding_part = false
				if coffee:
					coffee = false
					entity.use_airlock(true, model)
					airlock_submitted.emit(true)
				else:
					entity.use_airlock(current_cabinet.correct, model)
					airlock_submitted.emit(current_cabinet.correct)
				hide_parts()
				can_read_text = false
				action_wait.start()
			elif entity.entity_type == "intro_cutscene":
				holding_part = true
				switch_part(3)
				model = 3
				took_coffee.emit()
	
	if state == STATE.FREE:
		yaw.rotate_y(yaw_input)
		pitch.rotate_x(pitch_input)
		pitch.rotation.x = clamp(pitch.rotation.x, -1.5, 1.5)
		yaw_input = 0.0
		pitch_input = 0.0
		
		show_tooltip.emit(ray.is_colliding() and can_use)
		
		if focused and Input.is_action_just_pressed("dismiss_text") and can_read_text:
			next_text.emit()

func _unhandled_input(event):
		if event is InputEventMouseMotion:
			if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
				yaw_input = -event.relative.x * mouse_sensitivity * horizontal_speed
				pitch_input = -event.relative.y * mouse_sensitivity * vertical_speed

func exit_cabinet():
	cam_target.global_basis = previous_basis
	cam_target.position = previous_position
	camera.weight = 0.0
	camera.fov = 90.0
	current_cabinet.close_cabinet()
	state = STATE.FREE
	holding_part = true

func switch_part(index: int):
	hide_parts()
	part_models[index].set_visible(true)

func hide_parts():
	for part in part_models:
		part.set_visible(false)


func _on_footstep_timer_timeout():
	can_step = true


func _on_action_wait_timeout():
	can_read_text = true
