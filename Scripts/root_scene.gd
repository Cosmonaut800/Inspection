extends Node3D

@onready var main_menu := $MainMenu
@onready var pause_menu := $PauseMenu

var world_scene = preload("res://Scenes/world.tscn")
var world: Node3D

var horizontal_speed := 1.0
var vertical_speed := 1.0

func _on_world_reset():
	world.queue_free()
	world = world_scene.instantiate()
	world.set_process_mode(Node.PROCESS_MODE_PAUSABLE)
	world.skip_intro = true
	add_child(world)
	move_child(world, 0)
	world.reset.connect(_on_world_reset)
	world.update_horizontal_speed(horizontal_speed)
	world.update_vertical_speed(vertical_speed)
	pause_menu.world = world

func _on_main_menu_start_game_pressed(skip_intro: bool):
	main_menu.camera.set_current(false)
	world = world_scene.instantiate()
	world.set_process_mode(Node.PROCESS_MODE_PAUSABLE)
	world.skip_intro = skip_intro
	add_child(world)
	move_child(world, 0)
	world.reset.connect(_on_world_reset)
	world.player.camera.set_current(true)
	main_menu.queue_free()
	world.update_horizontal_speed(horizontal_speed)
	world.update_vertical_speed(vertical_speed)
	pause_menu.world = world
	pause_menu.can_pause = true

func _on_options_menu_change_horizontal_speed(new_horizontal_speed):
	horizontal_speed = new_horizontal_speed
	if world:
		world.update_horizontal_speed(horizontal_speed)

func _on_options_menu_change_vertical_speed(new_vertical_speed):
	vertical_speed = new_vertical_speed
	if world:
		world.update_vertical_speed(vertical_speed)
