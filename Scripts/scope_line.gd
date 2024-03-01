extends Node2D

var timer := 0.0
var points := PackedVector2Array()
var bg: Texture2D = preload("res://Materials/Textures/osc_screen.png")

func _process(delta):
	timer += delta
	
	for i in range(256):
		points.append(Vector2(i * 1.0, 128.0 + 64.0 * sin(i * PI/256.0) * cos(i/3.141592 - 13.72 * timer) * sin(i/20.0 + timer)))
	
	queue_redraw()

func _draw():
	draw_texture(bg, Vector2.ZERO)
	draw_polyline(points, Color.BLACK, 1.0, true)
	points = []
