extends Node3D

@export var cabinets: Array[Node3D] = []

var easy_cabinet
var medium_cabinet
var hard_cabinet

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
	easy_cabinet.difference_max = 1.0
	medium_cabinet.difference_min = 0.3
	medium_cabinet.difference_max = 0.8
	hard_cabinet.difference_min = 0.2
	hard_cabinet.difference_max = 0.4
	
	easy_cabinet.activate()
	medium_cabinet.activate()
	hard_cabinet.activate()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
