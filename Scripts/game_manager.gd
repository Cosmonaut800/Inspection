extends Node3D

@export var cabinets: Array[Node3D] = []

@onready var timer := $CabinetWait
@onready var text_box := $TextBox
@onready var text_timer := $TextTimer
@onready var player := $Player

var easy_cabinet
var medium_cabinet
var hard_cabinet

var difficulty := 0

var correct_cabinets := 0

# Called when the node enters the scene tree for the first time.
func _ready():
	var index1 := 0
	var index2 := 0
	var choices = [[0, 1, 2], [3, 4, 5], [6, 7, 8]]
	
	index1 = randi_range(0, 2) # assuming nine cabinets
	index2 = randi_range(0, 2)
	easy_cabinet = cabinets[choices[index1][index2]]
	choices.remove_at(index1)
	index1 = randi_range(0, 1)
	index2 = randi_range(0, 2)
	medium_cabinet = cabinets[choices[index1][index2]]
	choices.remove_at(index1)
	index2 = randi_range(0, 2)
	hard_cabinet = cabinets[choices[0][index2]]
	
	easy_cabinet.difference_min = 0.5
	easy_cabinet.difference_max = 0.55
	easy_cabinet.completed.connect(on_cabinet_completed)
	easy_cabinet.timeout.connect(on_cabinet_timeout)
	medium_cabinet.difference_min = 0.4
	medium_cabinet.difference_max = 0.8
	medium_cabinet.completed.connect(on_cabinet_completed)
	medium_cabinet.timeout.connect(on_cabinet_timeout)
	hard_cabinet.difference_min = 0.2
	hard_cabinet.difference_max = 0.4
	hard_cabinet.completed.connect(on_cabinet_completed)
	hard_cabinet.timeout.connect(on_cabinet_timeout)
	
	easy_cabinet.activate()
	
	display_text_box("INTRO", 6.0)

func display_text_box(text_index: String, duration: float):
	text_box.show_text(text_index)
	text_timer.wait_time = duration
	text_timer.start()

func on_cabinet_completed():
	display_text_box("CABINET_COMPLETE", 5.0)

func on_cabinet_timeout():
	player.exit_cabinet()
	display_text_box("YOU_LOSE", 4.0)

func _on_cabinet_wait_timeout():
	if difficulty == 0:
		medium_cabinet.activate()
		difficulty = 1
	elif difficulty == 1:
		hard_cabinet.activate()
		difficulty = 2

func _on_air_lock_activated():
	timer.start()


func _on_text_timer_timeout():
	text_box.hide_text()


func _on_player_airlock_submitted(correct):
	if correct:
		correct_cabinets += 1
		if correct_cabinets >= 3:
			display_text_box("YOU_WIN", 4.0)
	else:
		display_text_box("YOU_LOSE", 4.0)
