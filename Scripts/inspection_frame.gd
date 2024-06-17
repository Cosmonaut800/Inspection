extends Node3D

@export var player:CharacterBody3D
@export var num_of_parts := 4
@export var timer := 60.0
@export var difference_max := 1.0 #Should be above difference_min
@export var difference_min := 0.5 #Should never be above 0.5

@onready var cabinet_UI := $Control
@onready var timer_label := $Control/bg/Timer/Time
@onready var cam_target := $CameraTarget
@onready var oscilloscope := $Oscilloscope
@onready var thermal_cam := $ThermalCam
@onready var acoustic_tap := $AcousticTap
@onready var acoustic_tooltip := $Control/bg/AcousticTooltip
@onready var drag_tooltip := $Control/bg/DragTooltip
@onready var hitbox := $Area3D/CollisionShape3D
@onready var hitbox2 := $Area3D/CollisionShape3D2
@onready var anim_tree := $OmniLight3D/AnimationTree
@onready var alarm_sound := $Audio/AlarmSound
@onready var explosion_sound := $Audio/ExplosionSound
@onready var click := $Audio/Click
@onready var door := $cabinet2/cabinet_door2

@onready var particles := $GPUParticles3D
@onready var ground_parts := [	$PartsOnFloor/PartGroup1,
								$PartsOnFloor/PartGroup2,
								$PartsOnFloor/PartGroup3]
@onready var cabinet_parts := [	$PartsInCabinet/PartGroup1,
								$PartsInCabinet/PartGroup2,
								$PartsInCabinet/PartGroup3]

const LOOP_THRESHOLD := 400

var entity_type := "inspection_frame"

var part_template = preload("res://Scenes/part.tscn")

var open := false

var parts = []
var position_targets = []
var current_index := 0
var aberrant := 0
var model := 0

var correct = true

enum PROPERTIES {EM_FIELD, THERMAL, ACOUSTIC}
var property := PROPERTIES.EM_FIELD

var regions = {"AudioRegion1": 0, "AudioRegion2": 1, "AudioRegion3": 2, "AudioRegion4": 3}
var nominal_sound;
var aberrant_sound;

signal completed
signal timeout

# Called when the node enters the scene tree for the first time.
func _ready():
	aberrant = randi_range(0, num_of_parts-1)
	#model = randi_range(0, 2)
	
	for i in range(num_of_parts):
		position_targets.append(Node3D.new())
		add_child(position_targets[-1])
		position_targets[-1].scale = Vector3(1.0/(1.0 + i), 1.0/(1.0 + i), 1.0/(1.0 + i))
		position_targets[-1].position = Vector3(i * 1.0 * position_targets[-1].scale.x, -0.2 + 0.2*(1.0 - position_targets[i].scale.y), -0.2)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if open:
		var plane_normal:Vector3 = (cam_target.global_position - global_position).normalized()
		var drop_plane = Plane(plane_normal, plane_normal.dot(cam_target.global_position) - 0.65)
		var position3D = drop_plane.intersects_ray(player.camera.project_ray_origin(get_viewport().get_mouse_position()), player.camera.project_ray_normal(get_viewport().get_mouse_position()))
		timer -= delta
		
		if position3D:
			oscilloscope.global_position = position3D
			thermal_cam.global_position = position3D
			acoustic_tap.global_position = position3D
			read_oscilloscope(oscilloscope.position.y)
		for i in range(num_of_parts):
			parts[i].position += (position_targets[i].position - parts[i].position).length() * 10.0 * delta * (position_targets[i].position - parts[i].position).normalized()
			parts[i].scale += (position_targets[i].scale - parts[i].scale).length() * 10.0 * delta * (position_targets[i].scale - parts[i].scale).normalized()
		
		thermal_cam.material.set_shader_parameter("basePosition", parts[current_index].global_position)
		
		var time_str = "%1.0f:%02.0f" % [floor(timer/60.0), floor(fmod(timer, 60.0))]
		timer_label.text = time_str
		
		
		if timer <= 0.0: timeout.emit()

func activate():
	hitbox.disabled = false
	hitbox2.disabled = false
	alarm_sound.play()
	explosion_sound.play()
	particles.emitting = true
	door.set_visible(false)
	ground_parts[model].set_visible(true)
	anim_tree.set("parameters/conditions/opened", false)
	anim_tree.set("parameters/conditions/blinking", true)

func deactivate():
	hitbox.disabled = true
	hitbox2.disabled = true
	anim_tree.set("parameters/conditions/blinking", false)
	anim_tree.set("parameters/conditions/finished", true)
	completed.emit()

func open_cabinet():
	open = true
	cabinet_UI.set_visible(true)
	ground_parts[model].set_visible(false)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	alarm_sound.stop()
	
	var em_nominal = {"location": randf_range(0.2, 0.8), "a": randf_range(0.005, 0.01), "b": randf_range(-2.0, 2.0), "c": randf_range(-16.0, -64.0), "ofs": randi_range(64, 192)}
	var thermal_nominal = {"location": randf_range(0.0, 0.4), "radius": randf_range(0.16, 0.17), "attenuation": randf_range(0.8, 1.2)}
	
	var em_aberrant = {"location": 0.0, "a": 0.0, "b": 0.0, "c": 0, "ofs": 0}
	var thermal_aberrant = {"location": 0.0, "radius": 0.0, "attenuation": 0.0}
	
	var acoustic_nominal := randi_range(0, 3)
	var acoustic_aberrant := 0
	
	if property == PROPERTIES.EM_FIELD:
		generate_em_aberrant(em_nominal, em_aberrant)
		thermal_aberrant = thermal_nominal
		acoustic_aberrant = acoustic_nominal
	elif property == PROPERTIES.THERMAL:
		generate_thermal_aberrant(thermal_nominal, thermal_aberrant)
		em_aberrant = em_nominal
		acoustic_aberrant = acoustic_nominal
	elif property == PROPERTIES.ACOUSTIC:
		acoustic_aberrant = generate_acoustic_aberrant(acoustic_nominal)
		em_aberrant = em_nominal
		thermal_aberrant = thermal_nominal
	
	for i in range(num_of_parts):
		parts.append(part_template.instantiate())
		add_child(parts[-1])
		parts[-1].scale = position_targets[i].scale
		parts[-1].position = position_targets[i].position
		parts[-1].em_spike = em_nominal
		parts[-1].thermal_spike = thermal_nominal
		parts[-1].acoustic_spike = acoustic_nominal
	
	for part in parts:
		part.model_selection = model
		part.switch_visual(part.model_selection)
	parts[current_index].show_audio_regions()
	
	parts[aberrant].em_spike = em_aberrant
	parts[aberrant].thermal_spike = thermal_aberrant
	parts[aberrant].acoustic_spike = acoustic_aberrant
	
	configure_thermal_cam()
	acoustic_tap.nominal_sound.stream = nominal_sound
	acoustic_tap.aberrant_sound.stream = aberrant_sound
	
	anim_tree.set("parameters/conditions/finished", false)
	anim_tree.set("parameters/conditions/opened", true)

func close_cabinet():
	open = false
	player.switch_part(parts[current_index].model_selection)
	for part in parts:
		part.queue_free()
	parts = []
	cabinet_UI.set_visible(false)
	cabinet_parts[model].set_visible(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	deactivate()

func generate_em_aberrant(em_nominal, em_aberrant):
	var counter := 0
	
	em_aberrant.location = randf_range(0.2, 0.8)
	em_aberrant.a = randf_range(0.005, 0.01)
	em_aberrant.b = randf_range(-2.0, 2.0)
	em_aberrant.c = randf_range(-16, -64)
	em_aberrant.ofs = randf_range(64, 192)
	
	while abs(em_aberrant.location - em_nominal.location) <= (difference_min)*(0.8-0.2) or abs(em_aberrant.location - em_nominal.location) >= (difference_max)*(0.8-0.2):
		em_aberrant.location = randf_range(0.2, 0.8)
		counter += 1
		if counter > LOOP_THRESHOLD: break
	counter = 0
	
	while abs(em_aberrant.a - em_nominal.a) <= (difference_min)*(0.01-0.005) or abs(em_aberrant.a - em_nominal.a) >= (difference_max)*(0.01-0.005):
		em_aberrant.a = randf_range(0.005, 0.01)
		counter += 1
		if counter > LOOP_THRESHOLD: break
	counter = 0
	
	while abs(em_aberrant.b - em_nominal.b) <= (difference_min)*(2.0+2.0) or abs(em_aberrant.b - em_nominal.b) >= (difference_max)*(2.0+2.0):
		em_aberrant.b = randf_range(-2.0, 2.0)
		counter += 1
		if counter > LOOP_THRESHOLD: break
	counter = 0
	
	while abs(em_aberrant.c - em_nominal.c) <= (difference_min)*(64-16) or abs(em_aberrant.c - em_nominal.c) >= (difference_max)*(64-16):
		em_aberrant.c = randf_range(-16, -64)
		counter += 1
		if counter > LOOP_THRESHOLD: break
	counter = 0
	
	while abs(em_aberrant.ofs - em_nominal.ofs) <= (difference_min)*(192-64) or abs(em_aberrant.ofs - em_nominal.ofs) >= (difference_max)*(192-64):
		em_aberrant.ofs = randf_range(64, 192)
		counter += 1
		if counter > LOOP_THRESHOLD: break

func generate_thermal_aberrant(thermal_nominal, thermal_aberrant):
	var counter := 0
	
	while abs(thermal_aberrant.location - thermal_nominal.location) <= (difference_min)*(0.4-0.0) or abs(thermal_aberrant.location - thermal_nominal.location) >= (difference_max)*(0.4-0.0):
		thermal_aberrant.location = randf_range(0.0, 0.4)
		counter += 1
		if counter > LOOP_THRESHOLD: break
	counter = 0
	
	while abs(thermal_aberrant.radius - thermal_nominal.radius) <= (difference_min)*(0.17-0.16) or abs(thermal_aberrant.radius - thermal_nominal.radius) >= (difference_max)*(0.17-0.16):
		thermal_aberrant.radius = randf_range(0.16, 0.17)
		counter += 1
		if counter > LOOP_THRESHOLD: break
	counter = 0
	
	while abs(thermal_aberrant.attenuation - thermal_nominal.attenuation) <= (difference_min)*(1.2-0.8) or abs(thermal_aberrant.attenuation - thermal_nominal.attenuation) >= (difference_max)*(1.2-0.8):
		thermal_aberrant.attenuation = randf_range(0.8, 1.2)
		counter += 1
		if counter > LOOP_THRESHOLD: break

func generate_acoustic_aberrant(acoustic_nominal) -> int:
	var acoustic_aberrant := randi_range(0, 3)
	var counter := 0
	
	while acoustic_nominal == acoustic_aberrant:
		acoustic_aberrant = randi_range(0, 3)
		counter += 1
		if counter > LOOP_THRESHOLD: break
	
	return acoustic_aberrant

func read_oscilloscope(pos: float):
	pos = (pos + 0.2)/0.4
	var weight = 1.0 - clamp(abs(pos - parts[current_index].em_spike.location), 0.0, 1.0)
	oscilloscope.a = weight * weight * parts[current_index].em_spike.a
	oscilloscope.b = weight * weight * parts[current_index].em_spike.b
	oscilloscope.c = weight * weight * parts[current_index].em_spike.c
	oscilloscope.ofs = weight * weight * parts[current_index].em_spike.ofs

func configure_thermal_cam():
	thermal_cam.material.set_shader_parameter("hotspotPos", parts[current_index].thermal_spike.location)
	thermal_cam.material.set_shader_parameter("hotspotRadius", parts[current_index].thermal_spike.radius)
	thermal_cam.material.set_shader_parameter("hotspotAtten", parts[current_index].thermal_spike.attenuation)
	thermal_cam.material.set_shader_parameter("basePosition", parts[current_index].global_position)

func _on_right_arrow_pressed():
	current_index += 1
	current_index = clamp(current_index, 0, num_of_parts-1)
	for i in range(num_of_parts):
		position_targets[i].scale = Vector3(1.0/(1.0 + abs(i-current_index)), 1.0/(1.0 + abs(i-current_index)), 1.0/(1.0 + abs(i-current_index)))
		position_targets[i].position = Vector3((i-current_index) * 1.0 * position_targets[i].scale.x, -0.2 + 0.2*(1.0 - position_targets[i].scale.y), -0.2)
	
	for part in parts:
		part.hide_audio_regions()
	parts[current_index].show_audio_regions()
	
	click.play()
	
	configure_thermal_cam()


func _on_left_arrow_pressed():
	current_index -= 1
	current_index = clamp(current_index, 0, num_of_parts-1)
	for i in range(num_of_parts):
		position_targets[i].scale = Vector3(1.0/(1.0 + abs(i-current_index)), 1.0/(1.0 + abs(i-current_index)), 1.0/(1.0 + abs(i-current_index)))
		position_targets[i].position = Vector3((i-current_index) * 1.0 * position_targets[i].scale.x, -0.2 + 0.2*(1.0 - position_targets[i].scale.y), -0.2)
	
	for part in parts:
		part.hide_audio_regions()
	parts[current_index].show_audio_regions()
	
	click.play()
	
	configure_thermal_cam()


func _on_osc_button_toggled(toggled_on):
	oscilloscope.set_visible(toggled_on)



func _on_therm_button_toggled(toggled_on):
	thermal_cam.set_visible(toggled_on)


func _on_aco_button_toggled(toggled_on):
	pass # Replace with function body.


func _on_jettison_button_pressed():
	if current_index != aberrant:
		correct = false
	
	player.exit_cabinet()


func _on_osc_button_button_down():
	oscilloscope.set_visible(true)
	drag_tooltip.set_visible(false)


func _on_osc_button_button_up():
	oscilloscope.set_visible(false)
	drag_tooltip.set_visible(true)


func _on_therm_button_button_down():
	thermal_cam.set_visible(true)
	drag_tooltip.set_visible(false)


func _on_therm_button_button_up():
	thermal_cam.set_visible(false)
	drag_tooltip.set_visible(true)


func _on_aco_button_button_down():
	acoustic_tap.set_visible(true)
	acoustic_tooltip.set_visible(true)
	acoustic_tap.active = true
	drag_tooltip.set_visible(false)


func _on_aco_button_button_up():
	acoustic_tap.set_visible(false)
	acoustic_tooltip.set_visible(false)
	acoustic_tap.active = false
	drag_tooltip.set_visible(true)


func _on_acoustic_tap_tapped(region):
	acoustic_tap.play_sound(property == PROPERTIES.ACOUSTIC and current_index == aberrant and regions[region] == parts[aberrant].acoustic_spike)
