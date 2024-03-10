extends Control

@onready var label := $Panel/Label
@onready var text_anim_tree := $TextTree

var texts = {"INTRO": "Hello! This is the intro text!",
	"CONGRATS": "Congratulations on completing a cabinet.",
	"YOU_WIN": "You won the game!",
	"YOU_LOSE": "You just lost the game."}

func show_text(text_index: String):
	text_anim_tree.set("parameters/conditions/clear", false)
	self.set_visible(true)
	label.text = texts[text_index]
	text_anim_tree.set("parameters/conditions/scroll", true)

func hide_text():
	text_anim_tree.set("parameters/conditions/scroll", false)
	text_anim_tree.set("parameters/conditions/clear", true)
	
	self.set_visible(false)
