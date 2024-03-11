extends Node3D

@export var model_selection := 0
@export var models: Array[Node3D] = []

@onready var audio_region_hitboxes := [$AudioRegions/AudioRegion1/CollisionShape3D, $AudioRegions/AudioRegion2/CollisionShape3D, $AudioRegions/AudioRegion3/CollisionShape3D, $AudioRegions/AudioRegion4/CollisionShape3D]

var em_spike = {"location": 0.0, "a": 0.0, "b": 0.0, "c": 0.0, "ofs": 0}
var thermal_spike = {"location": 0.0, "radius": 0.25, "attenuation": 1.0}
var acoustic_spike = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	switch_visual(model_selection)

func switch_visual(index: int):
	for model in models:
		model.set_visible(false)
	
	models[index].set_visible(true)

func hide_audio_regions():
	for region in audio_region_hitboxes:
		region.disabled = true

func show_audio_regions():
	for region in audio_region_hitboxes:
		region.disabled = false
