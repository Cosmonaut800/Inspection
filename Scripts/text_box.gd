extends Control

@onready var label := $Panel/Label
@onready var text_anim_tree := $TextTree

var texts = {"INTRO_1": "We're reading some alien lifeforms down in the engine room. Can you look through the window and see if you see anything?",
	"INTRO_2": "If they've broken anything down there, you'll need to fix it. Check out the poster by the door to make sure you're up to date on your tools.",
	"INTRO_3": "Ready? [Start Game]",
	"SHAPESHIFTER": "Oh! It's a shapeshifter! We don't need that hanging around, throw it in the disposal airlock on the far side of the room.",
	"THERES_MORE": "This is bad! They're going to mess with our engine parts for sure. Quick! Get them out of here before they ruin something important!",
	"CAREFUL": "But make sure you don't throw out any real parts! This ship'll explode without them!",
	"YOU_WIN": "You did it! ... Get back to work.",
	"YOU_LOSE": "You're fired..."}

func show_text(text_index: String):
	text_anim_tree.set("parameters/conditions/clear", false)
	self.set_visible(true)
	label.text = texts[text_index]
	text_anim_tree.set("parameters/conditions/scroll", true)

func hide_text():
	text_anim_tree.set("parameters/conditions/scroll", false)
	text_anim_tree.set("parameters/conditions/clear", true)
	
	self.set_visible(false)
