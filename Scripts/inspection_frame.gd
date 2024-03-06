extends Node3D

@export var num_of_parts := 4

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
		position_targets[-1].position = Vector3(i * 1.0 * position_targets[-1].scale.x, -0.2, -0.2)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if open:
		for i in range(num_of_parts):
			parts[i].position += (position_targets[i].position - parts[i].position).length() * 10.0 * delta * (position_targets[i].position - parts[i].position).normalized()
			parts[i].scale += (position_targets[i].scale - parts[i].scale).length() * 10.0 * delta * (position_targets[i].scale - parts[i].scale).normalized()
	

func open_cabinet():
	open = true
	cabinet_UI.set_visible(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	for i in range(num_of_parts):
		parts.append(part_template.instantiate())
		add_child(parts[-1])
		parts[-1].position = position_targets[i].position
		parts[-1].scale = position_targets[i].scale

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
		position_targets[i].position = Vector3((i-current_index) * 1.0 * position_targets[i].scale.x, -0.2, -0.2)


func _on_left_arrow_pressed():
	current_index -= 1
	current_index = clamp(current_index, 0, num_of_parts-1)
	for i in range(num_of_parts):
		position_targets[i].scale = Vector3(1.0/(1.0 + abs(i-current_index)), 1.0/(1.0 + abs(i-current_index)), 1.0/(1.0 + abs(i-current_index)))
		position_targets[i].position = Vector3((i-current_index) * 1.0 * position_targets[i].scale.x, -0.2, -0.2)


func _on_osc_button_toggled(toggled_on):
	print(toggled_on)
	oscilloscope.set_visible(toggled_on)


func _on_therm_button_toggled(toggled_on):
	thermal_cam.set_visible(toggled_on)


func _on_aco_button_toggled(toggled_on):
	pass # Replace with function body.
