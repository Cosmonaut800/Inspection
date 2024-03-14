extends Node3D

@export var cabinets: Array[Node3D] = []

@onready var timer := $CabinetWait
@onready var text_box := $TextBox
@onready var tooltip := $InteractTooltip
@onready var text_timer := $TextTimer
@onready var player := $Player
@onready var air_lock := $AirLock

@onready var intro_timer := $IntroCutscene/IntroTimer
@onready var shapeshifter_timer := $IntroCutscene/Shapeshifter
@onready var aliens_timer := $AliensCutscene/AliensSceneTimer
@onready var intro_anim := $IntroCutscene/AnimationTree
@onready var aliens_anim := $AliensCutscene/AnimationTree
@onready var intro_coffee := $IntroCutscene/coffee3
@onready var intro_coffee_hitbox := $IntroCutscene/Area3D/CollisionShape3D

@onready var music_timer := $Audio/MusicTimer
@onready var music_loops := [	$Audio/BreakOvr1,
								$Audio/BreakOvr2,
								$Audio/BreakOvr3,
								$Audio/BreakOvr4]

@onready var win_timer := $WinTimer
@onready var lose_timer := $LoseTimer
@onready var reset_timer := $ResetTimer
@onready var really_reset_timer := $ReallyResetTimer
@onready var out_tree := $outtree
var winner := false

var can_switch_tracks := false
var can_switch_cabinets := false

var sound1 := preload("res://Audio/446128__justinvoke__metal-clank-4.wav")
var sound2 := preload("res://Audio/446127__justinvoke__metal-clank-5.wav")
var sound3 := preload("res://Audio/446106__justinvoke__metal-clank-3.wav")

var easy_cabinet
var medium_cabinet
var hard_cabinet

var tool_selection = [0, 1, 2]

var difficulty := -1

var correct_cabinets := 0

var text_queue = []
var text_counter = 0

var game_started = false
var game_ended = false
var already_submitted = false

signal reset

# Called when the node enters the scene tree for the first time.
func _ready():
	var index1 := 0
	var index2 := 0
	var choices = [[0, 1, 2], [3, 4, 5], [6, 7, 8]]
	
	tool_selection.shuffle()
	
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
	
	choices = [0, 1, 2]
	choices.shuffle()
	
	easy_cabinet.property = tool_selection[0]
	easy_cabinet.model = choices[0]
	easy_cabinet.timer = 90.0
	easy_cabinet.difference_min = 0.5
	easy_cabinet.difference_max = 0.55
	easy_cabinet.nominal_sound = sound1
	easy_cabinet.aberrant_sound = sound3
	easy_cabinet.completed.connect(on_cabinet_completed)
	easy_cabinet.timeout.connect(on_cabinet_timeout)
	medium_cabinet.property = tool_selection[1]
	medium_cabinet.model = choices[1]
	medium_cabinet.difference_min = 0.4
	medium_cabinet.difference_max = 0.8
	medium_cabinet.nominal_sound = sound2
	medium_cabinet.aberrant_sound = sound3
	medium_cabinet.completed.connect(on_cabinet_completed)
	medium_cabinet.timeout.connect(on_cabinet_timeout)
	hard_cabinet.property = tool_selection[2]
	hard_cabinet.model = choices[2]
	hard_cabinet.difference_min = 0.2
	hard_cabinet.difference_max = 0.4
	hard_cabinet.nominal_sound = sound1
	hard_cabinet.aberrant_sound = sound2
	hard_cabinet.completed.connect(on_cabinet_completed)
	hard_cabinet.timeout.connect(on_cabinet_timeout)

func _process(_delta):
	if can_switch_tracks:
		can_switch_tracks = false
		
		if can_switch_cabinets:
			can_switch_cabinets = false
			if difficulty == -1:
				easy_cabinet.activate()
				difficulty = 0
			elif difficulty == 0:
				medium_cabinet.activate()
				difficulty = 1
			elif difficulty == 1:
				hard_cabinet.activate()
				difficulty = 2
			elif difficulty == 2:
				difficulty = 3
			
			for loop in music_loops:
				loop.stop()
			
			music_loops[difficulty].play()

func display_text_box(text_index: String):
	text_queue.push_back(text_index)
	if !text_box.visible:
		text_box.show_text(text_queue.pop_front())
		player.can_use = false

func display_text_box_timed(text_index: String, duration: float):
	#This function will interrupt whatever dialogue chain is currently set up!
	text_queue = []
	display_text_box(text_index)
	player.can_read_text = false
	text_timer.wait_time = duration
	text_timer.start()

func display_next_text():
	if game_started: text_counter += 1
	if text_queue.size() <= 0:
		text_box.hide_text()
		player.can_use = true
	else:
		text_box.show_text(text_queue.pop_front())
	
	if text_counter == 3:
		shapeshifter_timer.start()
		intro_anim.set("parameters/conditions/start", true)

func _on_text_timer_timeout():
	player.can_read_text = true
	display_next_text()

func on_cabinet_completed():
	air_lock.light.set_visible(true)
	air_lock.sound.play()
	#display_text_box("CABINET_COMPLETE")

func on_cabinet_timeout():
	player.exit_cabinet()
	player.hide_parts()
	player.holding_part = false
	winner = false
	lose_timer.start()
	difficulty = 2

func _on_cabinet_wait_timeout():
	timer.wait_time = 5.0
	can_switch_cabinets = true

func _on_air_lock_activated(counter):
	if counter == 1:
		aliens_timer.start()
	
	timer.start()

func on_next_text():
	display_next_text()

func _on_player_airlock_submitted(correct):
	if correct:
		correct_cabinets += 1
		if correct_cabinets == 1:
			pass
		if correct_cabinets >= 4 and !game_ended:
			win_timer.start()
			winner = true
			#display_text_box("YOU_WIN")
			game_ended = true
	elif !game_ended:
		lose_timer.start()
		winner = false
		#display_text_box("YOU_LOSE")
		difficulty = 2
		game_ended = true

func _on_music_timer_timeout():
	can_switch_tracks = true

func _on_break_ovr_1_finished():
	music_timer.start()

func _on_break_ovr_2_finished():
	music_timer.start()

func _on_break_ovr_3_finished():
	music_timer.start()

func _on_player_show_tooltip(show):
	tooltip.set_visible(show)


func _on_aliens_scene_timer_timeout():
	display_text_box("THERES_MORE")
	aliens_anim.set("parameters/conditions/start", true)


func _on_player_took_coffee():
	intro_coffee.set_visible(false)
	intro_coffee_hitbox.disabled = true
	air_lock.light.set_visible(true)
	air_lock.sound.play()


func _on_shapeshifter_timeout():
	display_text_box("SHAPESHIFTER")


func _on_intro_timer_timeout():
	game_started = true
	display_text_box("INTRO_1")
	display_text_box("INTRO_2")
	display_text_box("INTRO_3")


func _on_theres_more_timeout():
	display_text_box("THERES_MORE")


func _on_win_timer_timeout():
	display_text_box("YOU_WIN")
	winner = true
	reset_timer.start()


func _on_lose_timer_timeout():
	display_text_box("YOU_LOSE")
	winner = false
	reset_timer.start()


func _on_reset_timer_timeout():
	out_tree.set("parameters/conditions/lost", !winner)
	out_tree.set("parameters/conditions/won", winner)
	if !winner:
		really_reset_timer.start()


func _on_really_reset_timer_timeout():
	reset.emit()
