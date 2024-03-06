extends Node3D

@onready var line := $Screen/SubViewport/Line

@export var a := 0.0
@export var b := 0.0
@export var c := 0.0
@export var ofs := 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	line.a = a
	line.b = b
	line.c = c
	line.ofs = ofs
