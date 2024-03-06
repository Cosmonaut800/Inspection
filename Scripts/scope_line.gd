extends Node2D

var timer := 0.0
var points := PackedVector2Array()
var bg: Texture2D = preload("res://Materials/Textures/osc_screen.png")

var a := 0.0
var b := 0.0
var c := 0.0
var ofs := 0

func _process(delta):
	timer += delta
	
	for i in range(256):
		points.append(Vector2(i * 1.0, 128.0 + 64.0 * sin(i * PI/256.0) * cos(i/3.617 - 13.72 * timer) * sin(i/20.0 + timer) + a*(i-ofs)*(i-ofs) + b*(i-ofs) + c))
	
	queue_redraw()

func _draw():
	draw_texture(bg, Vector2.ZERO)
	draw_polyline(points, Color.GREEN, 1.0, true)
	points = []
