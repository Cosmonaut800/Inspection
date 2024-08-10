extends Control

@export var options_menu: Control

var focused := true
var world: Node3D
var can_pause := false

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel") and can_pause:
		if focused:
			pause_game()
		else:
			unpause_game()

func pause_game():
	set_visible(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	focused = false
	get_tree().set_pause(true)

func unpause_game():
	get_tree().set_pause(false)
	set_visible(false)
	focused = true
	if world.player.state == world.player.STATE.FREE:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_resume_pressed():
	unpause_game()

func _on_options_pressed():
	set_visible(false)
	options_menu.last_menu = self
	options_menu.open = true
	options_menu.set_visible(true)

func _on_quit_pressed():
	get_tree().quit()
