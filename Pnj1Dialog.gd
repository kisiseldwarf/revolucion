extends RichTextLabel

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

signal dialog_end

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_PNJ_dialog():
	show()
	while 1 == 1:
		print_debug("In while")
		if Input.is_action_pressed("ui_accept"):
			hide()
			emit_signal("dialog_end")
			break
