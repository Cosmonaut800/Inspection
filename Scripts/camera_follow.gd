extends Camera3D

@onready var target := $"../CameraTarget"
var weight = 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var travel = target.position - position
	
	weight += (1.0 - weight) * 2.0 * delta
	weight = clamp(weight, 0.0, 1.0)
	
	position = position + travel.length() * 10.0 * delta * travel.normalized()
	quaternion = quaternion.slerp(target.quaternion, weight)
