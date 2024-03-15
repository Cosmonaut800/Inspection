extends Node3D

var world_scene = preload("res://Scenes/world.tscn")
@onready var world := $World

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_world_reset():
	world.queue_free()
	world = world_scene.instantiate()
	add_child(world)
	world.reset.connect(_on_world_reset)
