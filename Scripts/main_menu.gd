extends Node3D

@export var options_menu: Control

@onready var camera := $Camera3D
@onready var background := $TestEnvironment
@onready var main_menu := $MenuBG
@onready var skip_intro_button := $MenuBG/StartGame/SkipIntroButton

signal start_game_pressed(skip_intro: bool)

func _on_start_game_pressed():
	start_game_pressed.emit(skip_intro_button.button_pressed)
	background.set_visible(false)
	main_menu.set_visible(false)

func _on_options_pressed():
	main_menu.set_visible(false)
	options_menu.last_menu = main_menu
	options_menu.open = true
	options_menu.set_visible(true)

func _on_quit_pressed():
	get_tree().quit()
