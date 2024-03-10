extends Control

@onready var label := $Panel/Label
@onready var text_anim_tree := $TextTree

var texts = {"INTRO": "Use your tools to find the fake parts in each cabinet that lights up.",
	"CABINET_COMPLETE": "Good! Now, take the part over to the air lock to jettison it.",
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
