extends Control

@onready var label := $Panel/Label
@onready var text_anim_tree := $TextTree

var texts = {"INTRO_1": "[Insert scene where you see a shapeshifting alien, learn to place it in the orange airlock on the far wall]",
	"INTRO_2": "Use your tools to find the fake parts in each cabinet that lights up. See the poster by the door for more info.",
	"INTRO_3": "The game will start once you dismiss this text box.",
	"CABINET_COMPLETE": "Good! Now, take the part over to the air lock to jettison it.",
	"YOU_WIN": "You won the game! [Insert winning scene]",
	"YOU_LOSE": "You just lost the game. [Insert losing scene]"}

func show_text(text_index: String):
	text_anim_tree.set("parameters/conditions/clear", false)
	self.set_visible(true)
	label.text = texts[text_index]
	text_anim_tree.set("parameters/conditions/scroll", true)

func hide_text():
	text_anim_tree.set("parameters/conditions/scroll", false)
	text_anim_tree.set("parameters/conditions/clear", true)
	
	self.set_visible(false)
