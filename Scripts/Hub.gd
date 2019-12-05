extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

#King elmar's place

# Called when the node enters the scene tree for the first time.
func _ready():
	var text = ["yo","mdr"]
	
	$Player.set_dialog(text)
	# to do
	#yield($Player,"dialog_finished")
	#show_text()

func show_text():
	var text = "mdr"
	var gui_handler = RichTextLabel.new()
	var font = Font.new()
	gui_handler.add_text(text)
	$GUI.add_child(gui_handler)
	gui_handler.show()

func _process(delta):
	pass
