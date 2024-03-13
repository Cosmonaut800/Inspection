extends Node3D

var active := false

@onready var ray := $RayCast3D
@onready var nominal_sound := $NominalSound
@onready var aberrant_sound := $AberrantSound
@onready var visualizer_array := $Screen/SubViewport/ColorRect.get_children()
@onready var spectrum := AudioServer.get_bus_effect_instance(2, 0)

const VU_COUNT = 8
const HEIGHT = 60
const FREQ_MAX = 11050.0
const MIN_DB = 60

signal tapped(region: String)

#Thanks to Phantasy Dev on youtube for this implementation of an audio visualizer!
func _process(delta):
	if active and Input.is_action_just_pressed("use_acoustic_tap"):
		if ray.is_colliding():
			tapped.emit(ray.get_collider().name)
	
	var prev_hz = 0
	for i in range(1, VU_COUNT+1):
		var hz = i * FREQ_MAX / VU_COUNT
		var f = spectrum.get_magnitude_for_frequency_range(prev_hz, hz)
		var energy = clamp((MIN_DB + linear_to_db(f.length()))/MIN_DB, 0, 1)
		var height = energy * HEIGHT
		prev_hz = hz
		
		var vis_rect = visualizer_array[i-1]
		var tween = get_tree().create_tween()
		tween.tween_property(vis_rect, "size", Vector2(vis_rect.size.x, 2.0 * height), 0.05)

func play_sound(aberrant: bool):
	if aberrant:
		aberrant_sound.pitch_scale = randf_range(0.9, 1.1)
		aberrant_sound.play()
	else:
		nominal_sound.pitch_scale = randf_range(0.9, 1.1)
		nominal_sound.play()
