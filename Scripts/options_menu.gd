extends Control

@onready var volume_slider := $VolumeSlider
@onready var horizontal_speed_slider := $HorizontalSpeedSlider
@onready var vertical_speed_slider := $VerticalSpeedSlider
@onready var volume_label := $VolumeSlider/Volume
@onready var music_label := $VolumeSlider/MusicSlider/Music
@onready var sfx_label := $VolumeSlider/SfxSlider/SoundEffects
@onready var horizontal_speed_label := $HorizontalSpeedSlider/HorizontalSpeed
@onready var vertical_speed_label := $VerticalSpeedSlider/VerticalSpeed

var last_menu: Node
var open := false

signal change_horizontal_speed(horizontal_speed: float)
signal change_vertical_speed(vertical_speed: float)

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel") and open:
		_on_back_pressed()

func _on_volume_slider_value_changed(value):
	volume_label.set_text("Volume: " + str(snapped(value, 1.0)) + "%")
	var master = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(master, linear_to_db(value/100.0))

func _on_horizontal_speed_slider_value_changed(value):
	horizontal_speed_label.set_text("Horizontal Speed: x" + str(snapped(value, 0.1)).pad_decimals(1))
	change_horizontal_speed.emit(value)

func _on_vertical_speed_slider_value_changed(value):
	vertical_speed_label.set_text("Vertical Speed: x" + str(snapped(value, 0.1)).pad_decimals(1))
	change_vertical_speed.emit(value)

func _on_back_pressed():
	open = false
	last_menu.set_visible(true)
	set_visible(false)

func _on_music_slider_value_changed(value):
	music_label.set_text("Music: " + str(snapped(value, 1.0)) + "%")
	var music = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_volume_db(music, linear_to_db(value/100.0))

func _on_sfx_slider_value_changed(value):
	sfx_label.set_text("Sound Effects: " + str(snapped(value, 1.0)) + "%")
	var sfx = AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_volume_db(sfx, linear_to_db(value/100.0))
