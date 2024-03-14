extends Node3D

@onready var light := $Light
@onready var sound := $Sound

@onready var models := [	$Part/Graphics1,
							$Part/Graphics2,
							$Part/Graphics3,
							$Part/coffee2]
@onready var anim_tree := $AnimationTree
@onready var reset_timer := $ResetTimer

var entity_type := "air_lock"

var counter := 0

signal activated(counter: int)

func hide_parts():
	for model in models:
		model.set_visible(false)

func use_airlock(correct: bool, model_index: int):
	hide_parts()
	counter += 1
	models[model_index].set_visible(true)
	anim_tree.set("parameters/conditions/correct", correct)
	anim_tree.set("parameters/conditions/incorrect", !correct)
	reset_timer.start()


func _on_reset_timer_timeout():
	anim_tree.set("parameters/conditions/correct", false)
	anim_tree.set("parameters/conditions/incorrect", false)
	light.set_visible(false)
	activated.emit(counter)
