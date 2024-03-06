extends Node3D

@export var num_of_parts := 4
@export var player:CharacterBody3D

@onready var cabinet_UI := $Control
@onready var cam_target := $CameraTarget
@onready var oscilloscope := $Oscilloscope
@onready var thermal_cam := $ThermalCam

var part_template = preload("res://Scenes/part.tscn")

var open := false

var parts = []
var position_targets = []
var current_index := 0
var aberrant := 0

# Called when the node enters the scene tree for the first time.
func _ready():
	aberrant = randi_range(0, num_of_parts)
	
	for i in range(num_of_parts):
		position_targets.append(Node3D.new())
		add_child(position_targets[-1])
		position_targets[-1].scale = Vector3(1.0/(1.0 + i), 1.0/(1.0 + i), 1.0/(1.0 + i))
		position_targets[-1].position = Vector3(i * 1.0 * position_targets[-1].scale.x, -0.2 + 0.2*(1.0 - position_targets[i].scale.y), -0.2)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if open:
		var plane_normal:Vector3 = (cam_target.global_position - global_position).normalized()
		var drop_plane = Plane(plane_normal, plane_normal.dot(cam_target.global_position) - 0.45)
		var position3D = drop_plane.intersects_ray(player.camera.project_ray_origin(get_viewport().get_mouse_position()), player.camera.project_ray_normal(get_viewport().get_mouse_position()))
		if position3D:
			oscilloscope.global_position = position3D
			read_oscilloscope(oscilloscope.position.y)
		for i in range(num_of_parts):
			parts[i].position += (position_targets[i].position - parts[i].position).length() * 10.0 * delta * (position_targets[i].position - parts[i].position).normalized()
			parts[i].scale += (position_targets[i].scale - parts[i].scale).length() * 10.0 * delta * (position_targets[i].scale - parts[i].scale).normalized()
	

func read_oscilloscope(pos: float):
	pos = (pos + 0.2)/0.4
	var weight = 1.0 - clamp(abs(pos - parts[current_index].em_spike.location), 0.0, 1.0)
	oscilloscope.a = weight * weight * parts[current_index].em_spike.a
	oscilloscope.b = weight * weight * parts[current_index].em_spike.b
	oscilloscope.c = weight * weight * parts[current_index].em_spike.c
	oscilloscope.ofs = weight * weight * parts[current_index].em_spike.ofs
	
	pass

func open_cabinet():
	open = true
	cabinet_UI.set_visible(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	var em_nominal = {"location": randf_range(0.2, 0.8), "a": randf_range(0.005, 0.01), "b": randf_range(-2.0, 2.0), "c": randf_range(-16.0, -64.0), "ofs": randi_range(64, 192)}
	
	for i in range(num_of_parts):
		parts.append(part_template.instantiate())
		add_child(parts[-1])
		parts[-1].scale = position_targets[i].scale
		parts[-1].position = position_targets[i].position
		parts[-1].em_spike = em_nominal

func close_cabinet():
	open = false
	for part in parts:
		part.queue_free()
	parts = []
	cabinet_UI.set_visible(false)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _on_right_arrow_pressed():
	current_index += 1
	current_index = clamp(current_index, 0, num_of_parts-1)
	for i in range(num_of_parts):
		position_targets[i].scale = Vector3(1.0/(1.0 + abs(i-current_index)), 1.0/(1.0 + abs(i-current_index)), 1.0/(1.0 + abs(i-current_index)))
		position_targets[i].position = Vector3((i-current_index) * 1.0 * position_targets[i].scale.x, -0.2 + 0.2*(1.0 - position_targets[i].scale.y), -0.2)


func _on_left_arrow_pressed():
	current_index -= 1
	current_index = clamp(current_index, 0, num_of_parts-1)
	for i in range(num_of_parts):
		position_targets[i].scale = Vector3(1.0/(1.0 + abs(i-current_index)), 1.0/(1.0 + abs(i-current_index)), 1.0/(1.0 + abs(i-current_index)))
		position_targets[i].position = Vector3((i-current_index) * 1.0 * position_targets[i].scale.x, -0.2 + 0.2*(1.0 - position_targets[i].scale.y), -0.2)


func _on_osc_button_toggled(toggled_on):
	print(toggled_on)
	oscilloscope.set_visible(toggled_on)


func _on_therm_button_toggled(toggled_on):
	thermal_cam.set_visible(toggled_on)


func _on_aco_button_toggled(toggled_on):
	pass # Replace with function body.
