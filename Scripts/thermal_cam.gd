extends Node3D

@onready var screen := $Screen
var material;

# Called when the node enters the scene tree for the first time.
func _ready():
	material = screen.get_active_material(0)
