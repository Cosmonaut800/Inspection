extends Node3D

@onready var light := $Light
@onready var sound := $Sound

var entity_type := "air_lock"

signal activated

func use_airlock():
	light.set_visible(false)
	activated.emit()
